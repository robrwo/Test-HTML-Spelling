#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use English qw( -no_match_vars );
use File::Slurp;
use Readonly;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

eval "use Text::Aspell" or eval "use Text::Ispell";
plan skip_all => 'Text::Aspell or Text::Ispell required' if $@;

eval "use Lingua::Ispell";
plan skip_all => 'Lingua::Ispell required' if $@;

eval "require Test::Pod::Spelling";
plan skip_all => 'Test::Pod::Spelling required' if $@;

Readonly::Scalar my $dictionary => 'xt/etc/custom-dictionary.txt';

Test::Pod::Spelling->import(
    spelling => {
	allow_words => [
	    (map { chomp($ARG); $ARG } read_file($dictionary))
	],
    },
);

all_pod_files_spelling_ok(qw( lib ));

done_testing;
