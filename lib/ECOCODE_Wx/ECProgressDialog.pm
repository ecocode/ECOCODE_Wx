package ECOCODE_Wx::ECProgressDialog;

=head1 NAME

    ECProgressDialog - Moose class around a customized Wx
    ProgressDialog

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
    along with ECOCODE_Wx.  If not, see
    <http://www.gnu.org/licenses/>.

    Copyright 2012 Erik Colson

=head1 AUTHOR

    Erik Colson

=cut

use Modern::Perl;

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;

extends 'Wx::ProgressDialog';
use Wx
    qw(wxID_ANY wxDefaultPosition wxDefaultSize wxPD_AUTO_HIDE wxPD_APP_MODAL );
use Wx::Event qw( );

use constant _TITLE => '--- EC Progress Dialog ---';
use constant _MESSAGE => 'Progress';

has 'title' => ( is => 'rw', isa => 'Str', default => _TITLE, );
has 'mainPanel' => ( is => 'rw', isa => 'Object', );
has 'panel'     => ( is => 'rw', isa => 'Object', );
has 'btnOK'     => ( is => 'rw', isa => 'Object', );
has 'skip'      => ( is => 'rw', isa => 'Bool', default => 0, );
has 'abort'     => ( is => 'rw', isa => 'Bool', default => 0, );

sub FOREIGNBUILDARGS {
    my $class  = shift;
    my %args   = @_;
    my $parent = exists $args{parent} ? $args{parent} : undef;
    my $title =
        exists $args{title} ? $args{title} : _TITLE;
    my $style   = exists $args{style}   ? $args{style}   : undef;
    my $message = exists $args{message} ? $args{message} : _MESSAGE;
    return ( $title, $message, $maximum, $parent, $style );
}

sub BUILD {
    my $self = shift;
}

sub _Update {
    my $self     = shift;
    my %args     = @_;
    my $value    = $args{value} // undef;
    my $message  = $args{message} // undef;
    my $skipRef  = \{ $self->abort };
    my $abortRef = \{ $self->abort };
    $$abortRef = !( $self->Update( $value, $message, $skipRef ) ) || $$abortRef;
}

sub setValue {
    my $self = shift;
    my $value = shift;
    $self->_Update(value => $value);
    return 1;
}

sub setMessage {
    my $self = shift;
    my $message = shift;
    $self->_Update(message => $message);
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
