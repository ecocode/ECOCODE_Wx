package ECOCODE_Wx::ECDataAwareTextCtrl;

use Moose;

extends 'ECOCODE_Wx::ECTextCtrl' ;

use DBIx::Class::Row;
use Wx qw (wxNullColour);
use Wx::Event qw( EVT_TEXT );

has 'dbicColumn' => ( is => 'rw', isa => 'Str', );
has 'currentRow' => ( is => 'rw', isa => 'Maybe[DBIx::Class::Row]', );

sub BUILD {
    my ($self,$args) = @_;
    EVT_TEXT ( $self, $self,
               sub {
                   my ($this,$event) = @_;
                   if ($this->isChanged == 1) {
                       $this->SetBackgroundColour( Wx::Colour->new('yellow'));
                       $this->Refresh();
                   } else {
                       $this->SetBackgroundColour( wxNullColour );
                       $this->Refresh();
                   }
               }
           );
}

sub isChanged {
    my $self = shift;
    my $curValue = $self->GetValue()||'';
    return undef if (!$self->currentRow());
    my $dbValue = $self->currentRow()->get_column($self->dbicColumn)||'';
    return 1 if ($curValue ne $dbValue);
    return 0;
}

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
    my $r = $self->currentRow() ;
    if ($r) {
        $self->SetValue($r->get_column($self->dbicColumn)||'');
    }
}

1;
