package Net::CouchDB::DB;

use strict;
use warnings;

sub new {
    my ( $class, $args ) = @_;
    my $couch = $args->{couch};
    my $name  = $args->{name};
    my $self = bless {
        couch => $couch,
        name  => $name,
    }, $class;

    # create the new database if needed
    if ( $args->{create} ) {
        my $res = $self->call( 'PUT', '' );
        my $code = $res->code;
        if ( $code == 201 ) {
            return $self;  # no need to check the content
        }
        elsif ( $code == 409 ) {
            die "A database named '$name' already exists\n";
        }
        else {
            my $uri = $self->couch->uri;
            die "The CouchDB at $uri responded with an unknown code "
              . "$code when trying to create a new database named "
              . "'$name'.\n";
        }
    }

    # TODO verify that this database exists
    return $self;
}

sub delete {
    my ($self) = @_;
    my $res = $self->call( 'DELETE', '' );
    my $code = $res->code;
    return if $code == 202;
    die "The database " . $self->name . " does not exist on the CouchDB "
      . "instance at " . $self->couch->uri . "\n"
      if $code == 404;
    die "Unknown status code '$code' while trying to delete the database "
      . $self->name . " from the CouchDB instance at "
      . $self->couch->uri ;
}

sub call {
    my ( $self, $method, $partial_uri ) = @_;
    $partial_uri = $self->name . $partial_uri;
    return $self->couch->call( $method, $partial_uri );
}

sub couch {
    my ($self) = @_;
    return $self->{couch};
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

1;

__END__

=head1 NAME

Net::CouchDB::DB - a single CouchDB database

=head1 DESCRIPTION

A full description of the module and its features.
May include numerous subsections (i.e. =head2, =head3, etc.)


=head1 METHODS

=head2 new(\%args)

 Named arguments:
    $couch  - required Net::CouchDb object
    $name   - required database name
    $create - optional boolean: should the database be created?

Creates a new L<Net::CouchDB::DB> object representing a database named
C<$name> residing on the C<$couch> server (a L<Net::CouchDB> object).
If C<$create> is true, the database is assumed not to exist and is created
on the server.  If attempts to create the database fail, an exception
is thrown.

=head2 delete

Deletes the database from the CouchDB server.  All associated documents
are also deleted.

=head2 name

Returns this database's name.

=head1 INTERNAL METHODS

These methods are primarily intended for internal use but documented here
for completeness.

=head2 call($method, $relative_uri)

Identical to L<Net::CouchDB/call> but C<$relative_uri> is relative
to the base URI of the current database.

=head2 couch

Returns a L<Net::CouchDB> object representing the server in which this
database resides.

=head1 AUTHOR

Michael Hendricks  <michael@ndrix.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 Michael Hendricks (<michael@ndrix.org>). All rights
reserved.
