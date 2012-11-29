#!perl
use v5.10;
use strict;
use warnings FATAL => 'all';

use Test::More;

unless ( $ENV{DEVELOPER_TESTING} ) {
    plan( skip_all => "Developer tests not required for installation" );
}

use lib 't/lib';

use Example;

use Test::WWW::Mechanize;

my $mech = Test::WWW::Mechanize->new();

$mech->get_ok('http://www.example.com/');

spelling_ok($mech->content, "spelling");

done_testing;

