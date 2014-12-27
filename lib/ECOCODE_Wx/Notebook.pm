package ECOCODE_Wx::Notebook;

=head1 NAME

    Notebook - Moose class around a customized Wx Notebook

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

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;
use Wx qw( wxID_ANY wxNB_TOP wxDefaultPosition wxDefaultSize );

extends 'Wx::Notebook';

has 'nameForLog' => ( is => 'rw', isa => 'Str', default => 'WxRAD-Notebook' );
has 'log'        => ( is => 'rw', isa => 'Object' );

sub FOREIGNBUILDARGS {
    my $class  = shift;
    my $args   = shift;
    my $parent = $args->{parent} // undef;
    my $id     = $args->{id} // wxID_ANY;
    my $pos    = wxDefaultPosition;
    my $height = $args->{height} // wxDefaultSize->GetHeight;
    my $width = $args->{width} // wxDefaultSize->GetWidth;
    my $size = Wx::Size->new( $width, $height );
    my $style = $args->{style} // wxNB_TOP;

    return ( $parent, $id, $pos, $size, $style );
}

sub BUILD {
    my $self = shift;
    my $args = shift;
    $self->log( Log::Log4perl::get_logger( $self->nameForLog ) );
}

no Moose;
# __PACKAGE__->meta->make_immutable;

1;
