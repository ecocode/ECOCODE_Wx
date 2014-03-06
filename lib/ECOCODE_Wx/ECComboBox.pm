package ECOCODE_WX::ECComboBox;

=head1 NAME

    ECComboBox - Moose class around a customized Wx ComboBox

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

    Copyright 2014 Erik Colson

=head1 AUTHOR

    Erik Colson

=cut

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;
use Wx qw( wxID_ANY wxDefaultPosition wxDefaultSize );

extends 'Wx::ComboBox';

has 'nameForLog' => ( is => 'rw', isa => 'Str', default => 'ECComboBox' );
has 'log'        => ( is => 'rw', isa => 'Object' );
has 'wxStaticText' => ( is => 'rw', isa => 'Maybe[Wx::StaticText]' );
has 'wxLabel'    => ( is => 'rw', isa => 'Str' );

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
    my $style     = exists $args{style}     ? $args{style}     : 0;
    my $value     = exists $args{value}     ? $args{value}     : '';
    my $choices   = exists $args{choices}   ? $args{choices}   : [];

    return ( $parent, $id, $value, $pos, $size, $choices, $style );
}

sub BUILD {
    my $self = shift;
    my $args = shift;
    $self->log( Log::Log4perl::get_logger( $self->nameForLog ) );
    if ( $args->{label} ) {
        $self->wxStaticText(
            Wx::StaticText->new( $self->GetParent(), wxID_ANY, $args->{label} ) );
    }
}

no Moose;
# __PACKAGE__->meta->make_immutable;

1;
