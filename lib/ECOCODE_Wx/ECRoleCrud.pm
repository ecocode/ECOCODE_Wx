package ECOCODE_Wx::ECRoleCrud;

use Moose::Role;
use Wx qw( wxDefaultPosition wxDefaultSize wxTE_PROCESS_ENTER
    wxHORIZONTAL wxEXPAND wxID_OK wxVSCROLL wxWANTS_CHARS wxALWAYS_SHOW_SB
    wxGROW wxID_ANY wxDEFAULT_FRAME_STYLE wxALL wxRIGHT );
use Wx::Event qw( EVT_BUTTON );
use Log::Log4perl;

# required attributs
requires ('panel', # associated Wx::Panel
          'tsz', # Wx::FlexGridSizer
          'log', # Log::Log4Perl
      ) ;
# required functions
requires ('close','defineWidgets','defineEvents','newRecord','saveRecord');

# define attributes

my @buttons = ( [qw/ butFind Find/], [qw/ butClose Close/],
                [qw/ butNew New/],   [qw/ butDelete Delete/],
                [qw/ butPrev Previous/], [qw/ butNext Next/],
                [qw/ butSave Save/]
);

foreach (@buttons) {
    my ( $Name, $label ) = ( $_->[0], $_->[1] );
    has $Name => ( is      => 'ro',
                   isa     => 'Wx::Button',
                   lazy    => 1,
                   default => sub { $_[0]->add_button($label) }
    );
}

has 'dataModifiedByUser' => ( is => 'rw', isa => 'Bool', default => 0 );

sub SaveOnExit {
    my $self = shift;
    # TODO: Implement
    # ask to save and perhaps saves data. or let user cancel exit
    # after eventually saving
    # return 1 for exit. 0 for cancel.
    return 1;
}

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

    $boxButtons->Add( $self->butFind,   1, wxRIGHT, 5 );
    $boxButtons->Add( $self->butNew,    1, wxRIGHT, 5 );
    $boxButtons->Add( $self->butDelete, 1, wxRIGHT, 5 );
    $boxButtons->Add( $self->butPrev,   1, wxRIGHT, 5 );
    $boxButtons->Add( $self->butNext,   1, wxRIGHT, 5 );
    $boxButtons->Add( $self->butSave,   1, wxRIGHT, 5 );
    $boxButtons->Add( $self->butClose );

    $self->tsz->Add( $boxButtons, 1, wxALL, 5 );
};

after defineEvents => sub {
    my $self = shift;

    my @buttons = ( [ $self->butClose,  \&CRUDClose ],
                    [ $self->butFind,   \&CRUDFind ],
                    [ $self->butNew,    \&CRUDNew ],
                    [ $self->butDelete, \&CRUDDelete ],
                    [ $self->butPrev,   \&CRUDPrev ],
                    [ $self->butNext,   \&CRUDNext ],
                    [ $self->butSave,   \&CRUDSave ]
    );

    foreach ( @buttons ) {
        my ($button, $method) = @$_;
        EVT_BUTTON(
            $self,
            $button,
            sub {
                $self->log->debug("Pushed ".$button->GetLabel());
                &$method($self);
            }
        );
    }
};

sub CRUDClose {
    my $self = shift;
    $self->Destroy() if (!$self->dataModifiedByUser || $self->SaveOnExit) ;
}
sub CRUDNew {
    my $self = shift;
    $self->newRecord();
}
sub CRUDSave {
    my $self = shift;
    $self->saveRecord();
}
sub CRUDPrev {
    my $self = shift;
}
sub CRUDNext {
    my $self = shift;
}
sub CRUDFind {
    my $self = shift;
}
sub CRUDDelete {
    my $self = shift;
}


no Moose::Role;
1;
