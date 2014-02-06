package ECOCODE_WX::ECDataAwareTextCtrl;

use Moose;

extends 'ECOCODE_Wx::ECTextCtrl' ;

use DBIx::Class::Row;

has 'dbicColumn' => ( is => 'rw', isa => 'Str', );
has 'currentRow' => ( is => 'rw', isa => 'Maybe[DBIx::Class::Row]', );

sub setToDBICResult {
    my $self = shift;
    my %args = @_;
    if ($args{result}) {
        $self->currentRow($args{result}) ;
        $self->refreshFromDB();
    }
}

sub refreshFromDB {
    my $self = shift;
    if ($self->currentRow()) {
        my $r = $self->currentRow() ;
        $self->SetValue($r->get_column($self->dbicColumn));
    }
}

1;
