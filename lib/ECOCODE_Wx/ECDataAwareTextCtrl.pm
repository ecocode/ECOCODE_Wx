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

sub _setValue {
    my ($self,$args) = @_;
    $self->ChangeValue($args->{value});
}

1;
