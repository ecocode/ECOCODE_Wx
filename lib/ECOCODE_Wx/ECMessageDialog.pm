package ECOCODE_Wx::ECMessageDialog;

=head1 NAME

    ECDialog - Moose class around a customized Wx MessageDialog

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

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;

extends 'Wx::MessageDialog';
use Wx qw(wxID_ANY wxCENTRE wxYES_NO wxCANCEL wxOK wxDefaultPosition);
use Wx::Event qw ();

sub FOREIGNBUILDARGS {
    my $class   = shift;
    my %args    = @_;
    my $parent  = $args{parent} // undef;
    my $string  = $args{string} // "Your answer";
    my $caption = $args{caption} // "Message";
    my $type    = $args{type} // "YESNOCANCEL";
    my $style   = $args{style} // wxCENTRE;
    if ( !defined $args{style} ) {
        $style |= wxYES_NO if $type =~ /YESNO/;
        $style |= wxCANCEL if $type =~ /CANCEL/;
        $style |= wxOK if $type =~ /OK/;
    }
    return ( $parent, $string, $caption, $style, wxDefaultPosition );
}

sub BUILD {
    my $self = shift;
    $self->Center();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
