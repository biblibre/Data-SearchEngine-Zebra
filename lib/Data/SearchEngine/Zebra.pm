package Data::SearchEngine::Zebra;

use Modern::Perl;
use Carp;
use ZOOM;
use Moose;
use Data::SearchEngine::Zebra::Config;

with 'Data::SearchEngine';


has conf => (is => 'rw', isa=>'Data::SearchEngine::Zebra::Config');
has conf_file => (is => 'ro', isa=>'Str');

sub search {
    my ($self, $query) = @_;

    my $zconn = $self->conf->connect;
    my $tmpresults = $zconn->search( $query->_zoom_query );

    return ($tmpresults, $zconn);
}

sub BUILD {
    my $self = shift;
    $self->conf( Data::SearchEngine::Zebra::Config->new({conf_file=>$self->conf_file}));
}

sub find_by_id {
}

1;

=pod

=encoding UTF-8

=head1 NAME

Data::SearchEngine::Zebra - Zebra search engine abstraction.

=head1 VERSION

version 0.02

=head1 ATTRIBUTES

=head2 conf

z3950 search configuration content

=head1 METHODS

=head2 search

Returns:
    ResultSet from ZOOM::Connection::search
    Connection to a Zebra server
    Data::SearchEngine::Zebra::Query object

=head1 AUTHOR

Juan Romay Sieira <juan.sieira@xercode.es>
Henri-Damien Laurent <henridamien.laurent@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Xercode Media Software.
This software is Copyright (c) 2012 by Biblibre.

This is free software, licensed under:

    The GNU General Public License, Version 3, 29 June 2007

=cut
