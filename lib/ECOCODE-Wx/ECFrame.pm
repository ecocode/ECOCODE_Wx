package ECOCODE::ECFrame;

use strict;
use warnings;
use feature "switch";

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;

extends 'Wx::Frame';
use Wx qw( wxDefaultPosition wxDefaultSize wxTE_PROCESS_ENTER
    wxHORIZONTAL wxEXPAND wxID_OK wxVSCROLL wxWANTS_CHARS wxALWAYS_SHOW_SB
    wxGROW wxID_ANY wxDEFAULT_FRAME_STYLE );
use Wx::Event qw( EVT_TEXT_ENTER EVT_TEXT EVT_BUTTON EVT_KEY_DOWN
    EVT_GRID_EDITOR_CREATED EVT_GRID_EDITOR_SHOWN EVT_GRID_SELECT_CELL
    EVT_SET_FOCUS EVT_KILL_FOCUS EVT_ACTIVATE EVT_COMMAND);

has 'panel'      => ( is => 'rw', isa => 'Wx::Panel' );
has 'nameForLog' => ( is => 'rw', isa => 'Str', default => 'ECFrame' );
has 'log'        => ( is => 'rw', isa => 'Object' );
has 'title'      => ( is => 'rw', isa => 'Str', default => 'ECFrame' );

sub defaultTitle { return "ECFrame" };

sub close {
    my $self = shift;
    $self->Destroy();
}

sub FOREIGNBUILDARGS {
    my $class  = shift;
    my %args   = @_;
    my $parent = exists $args{parent} ? $args{parent} : undef;
    my $id     = exists $args{id} ? $args{id} : wxID_ANY;
    my $title  = exists $args{title} ? $args{title} : $class->defaultTitle;
    my $pos    = wxDefaultPosition;
    my $size   = exists $args{size} ? $args{size} : Wx::GetDisplaySize();
    my $style  = exists $args{style} ? $args{style} : wxDEFAULT_FRAME_STYLE;
    my $name   = exists $args{name} ? $args{name} : "ECFrame";
    return ( $parent, $id, $title, $pos, $size, $style, $name );
}

sub BUILD {
    my $self = shift;

    $self->log( Log::Log4perl::get_logger( $self->nameForLog ) );
    $self->panel( Wx::Panel->new( $self, -1, wxDefaultPosition, wxDefaultSize
                ));
    $self->setDefaults;
    $self->defineEvents;
}

sub setDefaults {
    my $self = shift;
    $self->SetTitle($self->title);
}

sub defineEvents {
    my $self = shift;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
