package ECOCODE_Wx::ECRoleCrud;

use Moose::Role;
use Wx qw( wxDefaultPosition wxDefaultSize wxTE_PROCESS_ENTER
    wxHORIZONTAL wxEXPAND wxID_OK wxVSCROLL wxWANTS_CHARS wxALWAYS_SHOW_SB
    wxGROW wxID_ANY wxDEFAULT_FRAME_STYLE );

requires ('close','defineWidgets','panel','tsz') ;

has 'butNew' => ( is      => 'ro',
                  isa     => 'Wx::Button',
                  lazy    => 1,
                  default => sub { my $self = shift; $self->add_button("New") }
);
has 'butDelete' => (
                is      => 'ro',
                isa     => 'Wx::Button',
                lazy    => 1,
                default => sub { my $self = shift; $self->add_button("Delete") }
);
has 'butNext' => (is      => 'ro',
                  isa     => 'Wx::Button',
                  lazy    => 1,
                  default => sub { my $self = shift; $self->add_button("Next") }
);
has 'butPrev' => (
              is      => 'ro',
              isa     => 'Wx::Button',
              lazy    => 1,
              default => sub { my $self = shift; $self->add_button("Previous") }
);
has 'butSave' => (is      => 'ro',
                  isa     => 'Wx::Button',
                  lazy    => 1,
                  default => sub { my $self = shift; $self->add_button("Save") }
);
has 'butClose' => (
                 is      => 'ro',
                 isa     => 'Wx::Button',
                 lazy    => 1,
                 default => sub { my $self = shift; $self->add_button("Close") }
);

=head2 close

required method to close the current Frame

=cut

=head2 panel

required attribute holds the associated Wx::Panel

=cut

=head2 tsz

required attribute which holds the Wx::FlexGridSizer associated with the Frame

=cut

use Log::Log4perl;

sub add_button {
    my $self = shift;
    my $label = shift;

    my $ref_but = Wx::Button->new( $self->panel, -1,
                                   $label, wxDefaultPosition,
                                   wxDefaultSize
                               );
    return $ref_but;
}

after defineWidgets => sub {
    my $self = shift;

    my $boxButtons = Wx::BoxSizer->new(wxHORIZONTAL);

    $boxButtons->Add( $self->butNew );
    $boxButtons->Add( $self->butDelete );
    $boxButtons->Add( $self->butNext );
    $boxButtons->Add( $self->butPrev );
    $boxButtons->Add( $self->butSave );
    $boxButtons->Add( $self->butClose );

    $self->tsz->Add($boxButtons);
};

1;
