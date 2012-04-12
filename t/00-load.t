#!perl -T

use Test::More tests => 5;

BEGIN {
    use_ok( 'Data::SearchEngine::Zebra' );
    use_ok( 'Data::SearchEngine::Zebra::Config' );
    use_ok( 'Data::SearchEngine::Zebra::Query' );
    use_ok( 'Data::SearchEngine::Zebra::Results' );
    use_ok( 'Data::SearchEngine::Zebra::Item' );
}

diag( "Testing Data::SearchEngine::Zebra $Data::SearchEngine::Zebra::VERSION, Perl $], $^X" );
