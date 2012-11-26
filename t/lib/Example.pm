package Example;

use strict;
use warnings;

use base 'Exporter';

use Test::HTML::Spelling;

our @EXPORT = qw( spelling_ok );

my $sc = Test::HTML::Spelling->new(
);

$sc->speller->set_option('lang','en_GB');
$sc->speller->set_option('sug-mode','fast');

sub spelling_ok {
    $sc->spelling_ok(@_);
}

1;
