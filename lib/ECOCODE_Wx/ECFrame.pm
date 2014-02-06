package ECOCODE_Wx::ECFrame;

=head1 NAME

    ECFrame - Moose class around a customized Wx Frame

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 LICENSE

    This file is part of ECOCODE_Wx.

    ECOCODE_Wx is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published
    by the Free Software Foundation, either version 3 of the License,
    or (at your option) any later version.

    ECOCODE_Wx is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

    Copyright 2012 Erik Colson

=head1 AUTHOR

    Erik Colson

=cut

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
    $self->defineWidgets;
    $self->defineEvents;
}

sub setDefaults {
    my $self = shift;
    $self->SetTitle($self->title);
}

sub defineWidgets {
    my $self = shift;
}

sub defineEvents {
    my $self = shift;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
