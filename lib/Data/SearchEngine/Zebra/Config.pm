package Data::SearchEngine::Zebra::Config;

use Modern::Perl;
use Carp;
use ZOOM;
use XML::Simple;

use Moose;

has conf_file => ( is => 'rw', isa => 'Str');
has conf => ( is => 'rw' );
has z3950_connexions => ( is => 'rw', isa =>'HashRef' );

sub BUILD{
    my $self=shift;

    $self->conf_file( $ENV{Z3950_CONF} )  unless $self->conf_file;

    my $conf=eval{ XMLin( $self->conf_file,
        keyattr => ['id'], forcearray => ['listen', 'server', 'serverinfo'],
        suppressempty => '     ') };
    if ($@){
        croak "an error occured in decoding the xml record ".$self->conf." :".$@;
        return;
    }
    $self->conf($conf);
    # Zebra connections.
    $self->connect();
    warn Data::Dumper::Dumper($self);
}

sub connect{
    my ($self, $id) = @_;
    my $c        = $self->conf;
    #my $syntax   = $self->get_default("syntax") || "xml";
    my $syntax   = "xml";
    if (!$id) {
        my @servers=keys %{$c->{server}};
        $id=$servers[0];
    }
    my $zc;
    if (defined $self->z3950_connexions and defined $self->z3950_connexions->{$id}){
        $zc = $self->z3950_connexions->{$id};
    }
    else {
        my $host     = $c->{listen}->{$id}->{content};
        my $user     = $c->{serverinfo}->{$id}->{user};
        my $password = $c->{serverinfo}->{$id}->{password};
        my $auth     = $user && $password;

        # set options
        my $o = new ZOOM::Options();
        if ( $user && $password ) {
            $o->option( user     => $user );
            $o->option( password => $password );
        }

#        $o->option(async => 0);
#        $o->option(count => 150) ;
        $o->option( cqlfile => $c->{server}->{$id}->{cql2rpn} ) if ($c->{server}->{$id}->{cql2rpn});
        $o->option( cclfile => $c->{serverinfo}->{$id}->{ccl2rpn} ) if ($c->{server}->{$id}->{cql2rpn});
        $o->option( preferredRecordSyntax => $syntax );
#        $o->option( elementSetName => "F"); # F for 'full' as opposed to B for 'brief'

        $zc = create ZOOM::Connection( $o );
        $zc->connect($host, 0);
        carp "something wrong with the connection: ". $zc->errmsg() if $zc->errcode;

        $self->z3950_connexions({$id=> $zc});
    }
    return $zc;
}

sub reset_connexion {
    my $self = shift;
    my $server = shift;
    my $zcs = $self->z3950_connexions;
    for my $server (grep {/$server/} keys %$zcs ) {
        my $zc = $zcs->{$server};
        $zc->destroy() if $zc;
        undef $zcs->{$server};
    }
}


1;
=pod

=encoding UTF-8

=head1 NAME

Data::SearchEngine::Zebra::Config - Zebra search engine Configuration abstraction.

=head1 VERSION

version 0.01

=head1 ATTRIBUTES

=head2 conf_file

z3950 search configuration filename

=head2 conf

z3950 search configuration content

=head2 z3950_connexions

hash containing current connections to z3950 sources

=note



==head1 METHODS

=head2 connect

Returns:
    connection Connection to a Zebra server

=head2 reset_connection

Returns:
    connection Connection to a Zebra server

=head1 AUTHOR

Juan Romay Sieira <juan.sieira@xercode.es>
Henri-Damien Laurent <henridamien.laurent@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Xercode Media Software.
This software is Copyright (c) 2012 by Biblibre.

This is free software, licensed under:

    The GNU General Public License, Version 3, 29 June 2007

=cut
