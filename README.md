# VERSION

version v0.4.0

# SYNOPSIS

```perl
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
```

# DESCRIPTION

This module parses an HTML document, and checks the spelling of the
text and some attributes (such as the `title` and `alt` attributes).

It will not spellcheck the attributes or contents of elements
(including the contents of child elements) with the class
`no-spellcheck`.  For example, elements that contain user input, or
placenames that are unlikely to be in a dictionary (such as timezones)
should be in this class.

It will fail when an HTML document is not well-formed.

# METHODS

## ignore\_classes

This is an accessor method for the names of element classes that will
not be spellchecked.  It is also a constructor parameter.

It defaults to `no-spellcheck`.

## check\_attributes

This is an accessor method for the names of element attributes that
will be spellchecked.  It is also a constructor parameter.

It defaults to `title` and `alt`.

## ignore\_words

This is an accessor method for setting a hash of words that will be
ignored by the spellchecker.  Use it to specify a custom dictionary,
e.g.

```perl
use File::Slurp;

my %dict = map { chomp($_); $_ => 1 } read_file('custom');

$sc->ignore_words( \%dict );
```

## speller

```perl
my $sc = $sc->speller($lang);
```

This is an accessor that gives you access to a spellchecker for a
particular language (where `$lang` is a two-letter ISO 639-1 language
code).  If the language is omitted, it returns the default
spellchecker:

```
$sc->speller->set_option('sug-mode','fast');
```

Note that options set for the default spellchecker will not be set for
other spellcheckers.  To ensure all spellcheckers have the same
options as the default, use something like the following:

```perl
foreach my $lang (qw( en es fs )) {
    $sc->speller($lang)->set_option('sug-mode',
        $sc->speller->get_option('sug-mode')
    )
}
```

## langs

```perl
my @langs = $sc->langs;
```

Returns a list of languages (as two-letter ISO 639-1 codes) that there
are spellcheckers for.

This can be checked _after_ testing a document to ensure that the
document does not contain markup in unexpected languages.

## check\_spelling

```
if ($sc->check_spelling( $content )) {
  ..
}
```

Check the spelling of a document, and return true if there are no
spelling errors.

## spelling\_ok

```
$sc->spelling_ok( $content, $message );
```

Parses the HTML file and checks the spelling of the document text and
selected attributes.

# KNOWN ISSUES

## Using Test::HTML::Spelling in a module

Suppose you subclass a module like [Test::WWW::Mechanize](https://metacpan.org/pod/Test::WWW::Mechanize) and add a
`spelling_ok` method that calls ["spelling\_ok"](#spelling_ok).  This will work
fine, except that any errors will be reported as coming from your
module, rather than the test scripts that call your method.

To work around this, call the ["check\_spelling"](#check_spelling) method from within
your module.

# SEE ALSO

The following modules have similar functionality:

- [Apache::AxKit::Language::SpellCheck](https://metacpan.org/pod/Apache::AxKit::Language::SpellCheck)

# AUTHOR

Robert Rothenberg, `<rrwo at cpan.org>`

## Contributors and Acknowledgements

- Rusty Conover
- Murray Walker
- Interactive Information, Ltd.

# LICENSE AND COPYRIGHT

Copyright 2012-2014 Robert Rothenberg.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

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

# AUTHOR

Robert Rothenberg <rrwo@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2012-2018 by Robert Rothenberg.

This is free software, licensed under:

```
The Artistic License 2.0 (GPL Compatible)
```

# BUGS

Please report any bugs or feature requests on the bugtracker website
[https://github.com/robrwo/Test-HTML-Spelling/issues](https://github.com/robrwo/Test-HTML-Spelling/issues)

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# SUPPORT

## Perldoc

You can find documentation for this module with the perldoc command.

```
perldoc Test::HTML::Spelling
```

## Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

- MetaCPAN

    A modern, open-source CPAN search engine, useful to view POD in HTML format.

    [https://metacpan.org/release/Test-HTML-Spelling](https://metacpan.org/release/Test-HTML-Spelling)

- Search CPAN

    The default CPAN search engine, useful to view POD in HTML format.

    [http://search.cpan.org/dist/Test-HTML-Spelling](http://search.cpan.org/dist/Test-HTML-Spelling)

- RT: CPAN's Bug Tracker

    The RT ( Request Tracker ) website is the default bug/issue tracking system for CPAN.

    [https://rt.cpan.org/Public/Dist/Display.html?Name=Test-HTML-Spelling](https://rt.cpan.org/Public/Dist/Display.html?Name=Test-HTML-Spelling)

- AnnoCPAN

    The AnnoCPAN is a website that allows community annotations of Perl module documentation.

    [http://annocpan.org/dist/Test-HTML-Spelling](http://annocpan.org/dist/Test-HTML-Spelling)

- CPAN Ratings

    The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

    [http://cpanratings.perl.org/d/Test-HTML-Spelling](http://cpanratings.perl.org/d/Test-HTML-Spelling)

- CPANTS

    The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

    [http://cpants.cpanauthors.org/dist/Test-HTML-Spelling](http://cpants.cpanauthors.org/dist/Test-HTML-Spelling)

- CPAN Testers

    The CPAN Testers is a network of smoke testers who run automated tests on uploaded CPAN distributions.

    [http://www.cpantesters.org/distro/T/Test-HTML-Spelling](http://www.cpantesters.org/distro/T/Test-HTML-Spelling)

- CPAN Testers Matrix

    The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

    [http://matrix.cpantesters.org/?dist=Test-HTML-Spelling](http://matrix.cpantesters.org/?dist=Test-HTML-Spelling)

- CPAN Testers Dependencies

    The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

    [http://deps.cpantesters.org/?module=Test::HTML::Spelling](http://deps.cpantesters.org/?module=Test::HTML::Spelling)

## Bugs / Feature Requests

Please report any bugs or feature requests by email to `bug-test-html-spelling at rt.cpan.org`, or through
the web interface at [https://rt.cpan.org/Public/Bug/Report.html?Queue=Test-HTML-Spelling](https://rt.cpan.org/Public/Bug/Report.html?Queue=Test-HTML-Spelling). You will be automatically notified of any
progress on the request by the system.

## Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

[https://github.com/robrwo/Test-HTML-Spelling](https://github.com/robrwo/Test-HTML-Spelling)

```
git clone git://github.com/robrwo/Test-HTML-Spelling.git
```
