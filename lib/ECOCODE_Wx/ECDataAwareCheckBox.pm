package ECOCODE_Wx::ECDataAwareCheckBox;

use Moose;

extends 'ECOCODE_Wx::ECCheckBox';

use DBIx::Class::Row;
use Wx qw (wxNullColour);
use Wx::Event qw( EVT_CHECKBOX );

has 'dbicColumn' => ( is => 'rw', isa => 'Str', );
has 'currentRow' => ( is => 'rw', isa => 'Maybe[DBIx::Class::Row]', );

sub BUILD {
    my ( $self, $args ) = @_;
    EVT_CHECKBOX(
        $self, $self,
        sub {
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
    );
}

sub isChanged {
    my $self     = shift;
    my $curValue = $self->GetValue()||0;
    return undef if ( !$self->currentRow() );
    my $dbValue = $self->currentRow()->get_column( $self->dbicColumn )||0;
    return 1 if ( $curValue ne $dbValue );
    return 0;
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
    if ( $self->currentRow() ) {
        my $r = $self->currentRow();
        $self->SetValue( $r->get_column( $self->dbicColumn ) );
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
