=head1 NAME

Test::HTML::Spelling - Test the spelling of HTML documents

=head1 SYNOPSIS

  use Test::More;
  use Test::HTML::Spelling;

  use Test::WWW::Mechanize;

  my $sc = Test::HTML::Spelling->new(
      ignore_classes   => [qw( no-spellcheck )],
      check_attributes => [qw( title alt )],
  );

  $sc->speller->set_option('lang','en_GB');
  $sc->speller->set_option('sug-mode','fast');

  my $mech = Test::WWW::Mechanize->new();

  $mech->get_ok('http://www.example.com/');

  $sc->spelling_ok($mech->content, "spelling");

  done_testing;

=head1 DESCRIPTION

This module parses an HTML document, and checks the spelling of the
text and some attributes (such as the C<title> and C<alt> attributes).

It will not spellcheck the attributes or contents of elements
(including the contents of child elements) with the class
C<no-spellcheck>.  For example, elements that contain user input, or
placenames that are unlikely to be in a dictionary (such as timezones)
should be in this class.

It will fail when an HTML document if not well-formed.

=cut

package Test::HTML::Spelling;

use v5.10;

use Moose;

use curry;
use self;

use HTML::Parser;
use List::Util qw( reduce );
use Scalar::Util qw( looks_like_number );
use Search::Tokenizer;
use Test::Builder ();
use Text::Aspell;

use version 0.77; our $VERSION = version->declare('v0.1.0');

=head1 METHODS

=cut

=head2 ignore_classes

This is an accessor method for the names of element classes that will
not be spellchecked.  It is also a constructor paramater.

It defaults to C<no-spellcheck>.

=cut

has 'ignore_classes' => (
    is		=> 'rw',
    isa		=> 'ArrayRef[Str]',
    default	=> sub { [qw( no-spellcheck )] },
);

=head2 check_attributes

This is an accessor method for the names of element attributes that
will be spellchecked.  It is also a constructor paramater.

It defaults to C<title> and C<alt>.

=cut

has 'check_attributes' => (
    is		=> 'rw',
    isa		=> 'ArrayRef[Str]',
    default	=> sub { [qw( title alt )] },
);

has '_empty_elements' => (
    is		=> 'rw',
    isa		=> 'HashRef',
    default	=> sub { return { map { $_ => 1 } (qw( area base basefont br col frame hr img input isindex link meta param )) } },
);

=head2 ignore_words

This is an accessor method for setting a hash of words that will be
ignored by the spellchecker.  Use it to specify a custom dictionary,
e.g.

  use File::Slurp;

  my %dict = map { chomp($_); $_ => 1 } read_file('custom');

  $sc->ignore_words( \%dict );

=cut

has 'ignore_words' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { { } },
);

has 'tester' => (
    is => 'ro',
    default => sub {
	return Test::Builder->new();
    },
);

has 'tokenizer' => (
    is => 'rw',
    default => sub {

	my ($self) = @_;

	return Search::Tokenizer->new(

	    regex	=> qr/\p{Word}+(?:[-'.]\p{Word}+)*/,
	    lower	=> 0,
	    stopwords	=> $self->ignore_words,

	);

    },
);

has 'parser' => (
    is => 'ro',
    default => sub {
	my ($self) = @_;

	return HTML::Parser->new(

	    api_version		=> 3,

	    ignore_elements	=> [qw( script style )],
	    empty_element_tags	=> 1,

	    start_document_h	=> [ $self->curry::_start_document ],
	    start_h		=> [ $self->curry::_start_element, "tagname,attr,line,column" ],
	    end_h		=> [ $self->curry::_end_element,   "tagname,line" ],
	    text_h		=> [ $self->curry::_text,          "dtext,line,column" ],

	);

    },
);

=head2 speller

  $sc->speller->set_option('lang','en_GB');

This is an accessor that gives you access to the L<Text::Aspell>
object.  Use this to configure the spellchecker.

=cut

has 'speller' => (
    is => 'ro',
    default => sub {
	return Text::Aspell->new();
    },
);

has '_errors' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

has '_context' => (
    is		=> 'rw',
    isa		=> 'ArrayRef[HashRef]',
    default	=> sub { [ ] },
);

sub _context_depth {
    return scalar(@{$self->_context});
}

sub _context_top {
    return $self->_context->[0];
}

sub _is_ignored_context {
    if ($self->_context_depth) {
	return $self->_context_top->{ignore};
    } else {
	return 0;
    }
}

sub _push_context {
    my ($element, $ignore, $line) = @args;

    if ($self->_empty_elements->{$element}) {
	return;
    }

    unshift @{ $self->_context }, {
	element => $element,
	ignore  => $ignore || $self->_is_ignored_context,
	line    => $line,
    };
}

sub _pop_context {
    my ($element, $line) = @args;

    if ($self->_empty_elements->{$element}) {
	return;
    }

    my $context = shift @{ $self->_context };
    if ($element ne $context->{element}) {
	$self->tester->croak(sprintf("Expected element '%s' near input line %d", $context->{element}, $line // 0));
    }
}

sub _start_document {
    $self->_context([]);
    $self->_errors(0);

}

sub _start_element {
    my ($tag, $attr, $line) = @args;

    $attr //= { };

    my %classes = map { $_ => 1 } split /\s+/, ($attr->{class} // "");

    my $state  =  $self->_is_ignored_context;

    my $ignore = reduce {
	no warnings 'once';
	$a || $b;
    } ($state, map { $classes{$_} // 0 } @{ $self->ignore_classes } );

    $self->_push_context($tag, $ignore, $line);

    unless ($ignore) {

	foreach my $name (@{ $self->check_attributes }) {
	    $self->_text($attr->{$name}, $line) if (exists $attr->{$name});
	}
    }
}

sub _end_element {
    my ($tag, $line) = @args;

    $self->_pop_context($tag, $line);
}

sub _text {
    my ($text, $line) = (@args);

    unless ($self->_is_ignored_context) {

	my $iterator = $self->tokenizer->($text);

	while (my $word = $iterator->()) {

	    my $check = $self->speller->check($word) || looks_like_number($word);
	    unless ($check) {
	    	$self->_errors( 1 + $self->_errors );
	    	$self->tester->diag("Unrecognized word: '${word}' at line ${line}");
	    }

	}

    }

}

=head2 spelling_ok

    $sc->spelling_ok( $content, $message );

Parses the HTML file and checks the spelling of the document text and
selected attributes.

=cut

sub spelling_ok {
    my ($text, $message) = @args;

    $self->_errors(0);
    $self->parser->parse($text);
    $self->parser->eof;

    if ($self->_errors) {
	$self->tester->diag(
	    sprintf("Found %d spelling %s",
		    $self->_errors,
		    ($self->_errors == 1) ? "error" : "errors"));
    }

    $self->tester->ok($self->_errors == 0, $message);

}

 __PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Robert Rothenberg, C<< <rrwo at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Robert Rothenberg.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Test::HTML::Spelling
