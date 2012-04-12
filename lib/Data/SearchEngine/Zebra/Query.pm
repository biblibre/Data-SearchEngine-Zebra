package Data::SearchEngine::Zebra::Query;

use Modern::Perl;
use Carp qw(croak carp);
use ZOOM;

use Moose;

extends 'Data::SearchEngine::Query';

has conf => (
        is=>'rw'
        );
has _zoom_query => (
        is=>'rw',
        #isa=>'HashRef',
        #builder=>'_build__zoom_query'
        );
has _zconn => (
        is=>'rw',
        #isa=>'HashRef',
        );


sub _build_zoom_query {
    my $self = shift;
    my $conn = shift;
    my $type = shift;

    $type ||= $self->type;
    $conn ||= $self->connect;
    if ( $type !~ /PQF|CQL|CCL2RPN|CQL2RPN/i ) {
        carp "$type not implemented for zebra";
        return
    }
    if ( $type =~ /CCL2RPN|CQL2RPN/i ) {
        if ( !defined($conn) ) {
            carp "$type requires a connection to be processed";
            return
        }
    }
    $self->{_zoom_query} =
      eval { "ZOOM::Query::" . uc $type }->new( $self->query ,$conn);
}
sub BUILD {
   my $self=shift;
   $self->_zoom_query($self->_build_zoom_query($self->conf->connect, $self->type));
}
no Moose;
__PACKAGE__->meta->make_immutable;

1;
