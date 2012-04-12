#!/usr/bin/perl -w

use Data::SearchEngine::Zebra;
use Data::SearchEngine::Zebra::Query;
use Data::SearchEngine::Zebra::Results;
use Data::Dumper;

my $zebra = Data::SearchEngine::Zebra->new({conf_file=>'etc/zebra-conf.xml'});

# OPTIONS
#$zebra->set_default ("server", "biblio");
#$zebra->set_default ("async", 1);
#$zebra->set_default ("piggyback", 0);
#$zebra->set_default ("syntax", "xml");

# ==========   TEST   ================================================

my $tmpresults;   # Resultset from ZOOM::Connection::search
my $zconn;        # Connection to a Zebra server
my $seq;          # Data::SearchEngine::Query object
my $page = 1;     # First page
my $perpag = 1;   # Number of results per page

while ($page < 2){
    my $query=Data::SearchEngine::Zebra::Query->new({conf=>$zebra->conf,query=>"\@attr 1=1016 Huckleberry",type=>"PQF"});
    ($tmpresults, $zconn, $seq) = $zebra->search($query);
    my $zebraR = Data::SearchEngine::Zebra::Results->new( {query => $query, _zoom_resultset => $tmpresults });
    my ($res) = $zebraR->retrieve($zconn);
    warn Dumper($res);
    $page++;
}

