package ECOCODE_Wx::ECCheckBox;

=head1 NAME

    ECCheckBox - Moose class around a customized Wx CheckBox

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
use Wx qw( wxID_ANY wxDefaultPosition wxDefaultSize );

extends 'Wx::CheckBox';

has 'nameForLog' => ( is => 'rw', isa => 'Str', default => 'ECCheckBox' );
has 'log'        => ( is => 'rw', isa => 'Object' );
has 'label'      => ( is => 'rw', isa => 'Str' );

sub FOREIGNBUILDARGS {
    my $class  = shift;
    my %args   = @_;
    my $parent = exists $args{parent} ? $args{parent} : undef;
    my $id     = exists $args{id} ? $args{id} : wxID_ANY;
    my $pos    = wxDefaultPosition;
    my $height =
        exists $args{height} ? $args{height} : wxDefaultSize->GetHeight;
    my $width = exists $args{width} ? $args{width} : wxDefaultSize->GetWidth;
    my $size = Wx::Size->new( $width, $height );
    my $style = exists $args{style} ? $args{style} : 0;
    my $label = exists $args{label} ? $args{label} : '';

    return ( $parent, $id, $label, $pos, $size, $style );
}

sub BUILD {
    my $self  = shift;
    my $args  = shift;
    my $value = exists $args->{value} ? $args->{value} : undef;
    $self->log( Log::Log4perl::get_logger( $self->nameForLog ) );
    if ( $value ) {
        $self->SetValue($value);
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
