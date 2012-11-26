#!perl
use v5.10;
use strict;
use warnings FATAL => 'all';

use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

use Test::HTML::Spelling;

use Test::WWW::Mechanize;

my $mech = Test::WWW::Mechanize->new();

$mech->get_ok('http://www.example.com/');

use Lingua::StopWords;

my $stopwords = Lingua::StopWords::getStopWords('en');

foreach my $word (qw( IANA EXAMPLE.COM EXAMPLE.ORG ARPA IDN iana iana.org )) {
    $stopwords->{$word} = 1;
}

my $sc = Test::HTML::Spelling->new(
    ignore_words   => $stopwords,
    ignore_classes => [qw( no-speling )],
    );

$sc->speller->set_option('lang','en_GB');
$sc->speller->set_option('sug-mode','fast');

$sc->spelling_ok($mech->content, "spelling");

done_testing;

