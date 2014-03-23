package ECOCODE_Wx::ECComboSearchBox;

=head1 NAME

ECComboSearchBox - Combobox with search capabilities

=cut

use Moose;
extends 'ECOCODE_Wx::ECComboBox';

use Wx qw ( wxTIMER_ONE_SHOT wxTE_PROCESS_ENTER );
use Wx::Event qw( EVT_TEXT EVT_TEXT_ENTER EVT_TIMER EVT_CHILD_FOCUS);

has 'timer' =>
    ( is => 'ro', isa => 'Wx::Timer', default => sub { Wx::Timer->new() } );
has 'on_Enter' => (
    is      => 'ro',
    isa     => 'CodeRef',
    default => sub {
        sub { }
    },
);
has 'on_PopulateList' => (
    is      => 'ro',
    isa     => 'CodeRef',
    default => sub {
        sub { }
    }
);

around FOREIGNBUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    my %args = @_;
    $args{style} = wxTE_PROCESS_ENTER;
    return $class->$orig(%args);
};

sub BUILD {
    my $self = shift;
    my $args = shift;

    $self->timer->SetOwner($self);
    $self->defineEvents();
};

sub defineEvents {
    my $self = shift;

    EVT_TEXT(
        $self, $self,
        sub {
            my ( $this, $event ) = @_;
             print("char HIT\n");
            $this->timer->Start( 700, wxTIMER_ONE_SHOT )
                ;    # will get an event after xxx milliseconds
        }
    );

    EVT_TEXT_ENTER(
        $self,
        $self,
        sub {
            my ( $this, $event ) = @_ ;
             print("enter HIT\n");
            $this->Dismiss();
            $this->timer->Stop();
            &{$this->on_Enter};
        }
    );

    EVT_TIMER(
        $self,
        $self->timer,
        sub {
            my ($this, $event) = @_;
             print("timer event HIT\n");
            &{$self->on_PopulateList}; # callback
            $self->Popup() if (!$self->IsListEmpty()) ;
        }
    );

    EVT_CHILD_FOCUS(
        $self->GetParent(),
        sub {
            my ($this, $event) = @_;
            # kill the timer if the combobox loses focus
            if ($event->GetWindow() != $self) {
                $self->timer->Stop();
            }
        }
    );

};

__PACKAGE__->meta->make_immutable;

1;
