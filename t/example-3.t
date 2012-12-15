#!perl

use utf8;

use v5.10;
use strict;
use warnings FATAL => 'all';

use Test::More;

unless ( $ENV{DEVELOPER_TESTING} ) {
    plan( skip_all => "Developer tests not required for installation" );
}

use Test::HTML::Spelling;

my $content = "<html lang='es'><head><title lang='es'>Hola</title></head><body><p>Esta es espa&ntilde;ol.</p><p lang='en-US'>Hello</p><p>Amigo</p><p lang='fr'>du jour</p><p>Como estas</p></body></html>";

my $sc = Test::HTML::Spelling->new(
    ignore_words   => { },
    ignore_classes => [qw( no-speling )],
    );

$sc->speller->set_option('lang','en');
$sc->speller->set_option('sug-mode','fast');

$sc->spelling_ok($content, "spelling");

note(join(" ", $sc->langs));

done_testing;

