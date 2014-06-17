package ECOCODE_Wx::ECDataAwareCheckBox;

use Moose;
use Wx::Event qw( EVT_CHECKBOX );

extends 'ECOCODE_Wx::ECCheckBox';

has 'defaultContent' => ( is => 'ro', isa => 'Str', default=>0 );

with 'ECOCODE_Wx::ECRoleDataAwareWidget';

sub BUILD {
    my ($self,$args) = @_;
    EVT_CHECKBOX ( $self, $self, sub {shift->colorOnChanged(@_)} );
}

sub _setValue {
    my ($self,$args) = @_;
    $self->SetValue($args->{value});
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
