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

sub isChanged {
    my $self     = shift;
    my $curValue = $self->GetValue()||0;
    return undef if ( !$self->currentRow() );
    my $dbValue = $self->currentRow()->get_column( $self->dbicColumn )||$self->defaultContent;
    return 1 if ( $curValue != $dbValue );
    return 0;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
