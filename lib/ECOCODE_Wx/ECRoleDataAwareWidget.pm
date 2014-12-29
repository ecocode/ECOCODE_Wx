package ECOCODE_Wx::ECRoleDataAwareWidget;

# ABSTRACT: adds data aware to widgets

# VERSION

use Moose::Role;

use DBIx::Class::Row;
use Wx qw (wxNullColour);
use Wx::Event qw( EVT_CHECKBOX EVT_TEXT );

requires qw( defaultContent );
requires qw( _setValue )
    ;    # should set the value of the widget WITHOUT launching EVT

has 'dbicColumn' => ( is => 'rw', isa => 'Str', );
has 'currentRow' => ( is => 'rw', isa => 'Maybe[DBIx::Class::Row]', );
has 'dbValue'    => ( is => 'rw', isa => 'Item', default => undef, )
    ;    # dbValue is used to check for change

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

sub isChanged {
    my $this = shift;

    my $curValue = $this->GetValue();

    return ( $curValue ne $this->dbValue );
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
    my $r    = $self->currentRow();    # DBIx::Class::Row object
    if ($r) {
        my $column_info = $r->result_source()->column_info( $self->dbicColumn );
        $self->_setValue( { value => $r->get_column( $self->dbicColumn )
                                // $self->defaultContent
                          }
        );
        $self->dbValue( $self->GetValue() );
        $self->SetBackgroundColour(wxNullColour);
        $self->Refresh;
    }
}

no Moose::Role;

1;
