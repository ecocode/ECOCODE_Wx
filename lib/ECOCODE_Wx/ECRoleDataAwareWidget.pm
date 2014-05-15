package ECOCODE_Wx::ECRoleDataAwareWidget;

=head1 NAME

    ECRoleDataAwareWidget - adds data aware to widgets

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 LICENSE

    This file is part of ECOCODE_Wx.

    ECOCODE_Wx is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published
    by the Free Software Foundation, either version 3 of the License,
    or (at your option) any later version.

    ECOCODE_Wx is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

    Copyright 2014 Erik Colson

=head1 AUTHOR

    Erik Colson

=cut

use Moose::Role;

use DBIx::Class::Row;
use Wx qw (wxNullColour);
use Wx::Event qw( EVT_CHECKBOX EVT_TEXT );

requires qw( defaultContent );

has 'dbicColumn' => ( is => 'rw', isa => 'Str', );
has 'currentRow' => ( is => 'rw', isa => 'Maybe[DBIx::Class::Row]', );

sub colorOnChanged {
    my ( $this, $event ) = @_;
    if ( $this->isChanged == 1 ) {
        $this->SetBackgroundColour( Wx::Colour->new('yellow') );
        $this->Refresh();
    }
    else {
        $this->SetBackgroundColour(wxNullColour);
        $this->Refresh();
    }
}

sub setToDBICResult {
    my $self = shift;
    my %args = @_;
    if ( $args{result} ) {
        $self->currentRow( $args{result} );
        $self->refreshFromDB();
    }
}

sub refreshFromDB {
    my $self = shift;
    my $r = $self->currentRow() ;
    if ( $r ) {
        $self->SetValue( $r->get_column( $self->dbicColumn||$self->defaultContent ) );
    }
}

no Moose::Role;

1;
