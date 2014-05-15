package ECOCODE_Wx::ECDataAwareTextCtrl;

use Moose;
use Wx::Event qw( EVT_TEXT );

extends 'ECOCODE_Wx::ECTextCtrl' ;

has 'defaultContent' => ( is => 'ro', isa => 'Str', default=>'' );

with 'ECOCODE_Wx::ECRoleDataAwareWidget';

sub BUILD {
    my ($self,$args) = @_;
    EVT_TEXT ( $self, $self, sub {shift->colorOnChanged(@_)} );
}

sub isChanged {
    my $self = shift;
    my $curValue = $self->GetValue()||'';
    $curValue =~ s/\r\r/\r\n/g; # on macosx SetValue has changed \r\n in \r\r
    return undef if (!$self->currentRow());
    my $dbValue = $self->currentRow()->get_column($self->dbicColumn)||$self->defaultContent;
    return 1 if ($curValue ne $dbValue);
    return 0;
}

sub refreshFromDB {
    my $self = shift;
    my $r = $self->currentRow() ;
    if ($r) {
        $self->SetValue($r->get_column($self->dbicColumn)||'');
    }
}

1;
