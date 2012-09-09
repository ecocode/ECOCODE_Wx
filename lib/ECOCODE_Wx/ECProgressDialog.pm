package ECOCODE_Wx::ECProgressDialog;

=head1 NAME

    ECProgressDialog - Moose class around a customized Wx
    ProgressDialog

=head1 SYNOPSIS

    use Moose ;
    use ECOCODE_Wx::ECProgressDialog ;
    use Time::HiRes qw(usleep) ;

    my $progressBar =
        ECOCODE_Wx::ECProgressDialog->new(
            parent  => undef,
            title   => 'Test Progress Bar',
            message => 'Testing the process bar',
            maximum => 100,
        );

    usleep (500000); # Do some stuff

    foreach (1..99) {
        $progressBar->setValue($_); # setValue to value equal
                                    # as maximum will dismiss
                                    # the ProgressDialog
        usleep (100000); # Do some more stuff
    }

    $progressBar->close(); # dismiss

=head1 DESCRIPTION

    ECProgressDialog will launch a progressDialog with a
    progressbar. Subsequent calls to Update will update the
    progressBar.

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

use strict;
use warnings;

use Moose;
use MooseX::NonMoose::InsideOut;
use Log::Log4perl;

extends 'Wx::ProgressDialog';
use Wx qw( wxPD_AUTO_HIDE wxPD_APP_MODAL );

use constant _TITLE => '--- ECOCODE_Wx Progress Dialog ---' ;
use constant _MESSAGE => 'Progress' ;
use constant _MAXIMUM => 100 ;

has 'abort'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'value' => ( is => 'rw', isa => 'Num', default => 0, );
has 'maximum' => ( is => 'ro', isa => 'Num', default => _MAXIMUM, );
has 'message' => ( is => 'rw', isa => 'Str', default => _MESSAGE, );
has 'title' => ( is => 'ro', isa => 'Str', default => _TITLE, );

sub FOREIGNBUILDARGS {
    my $class  = shift;
    my %args   = @_;
    my $parent = $args{parent} // undef;
    my $title = $args{title} // _TITLE ;
    my $style   = $args{style} // (wxPD_AUTO_HIDE | wxPD_APP_MODAL);
    my $message = $args{message} // _MESSAGE;
    my $maximum = $args{maximum} // _MAXIMUM;
    return ( $title, $message, $maximum, $parent, $style );
}

sub close {
    my $self = shift;
    $self->Destroy();
}

sub Update {
    my $self = shift;
    my %args = @_;
    my $value   = $args{value}   // ($self->value // 0) ;
    my $message = $args{message} // '';
    my $abort = $self->SUPER::Update( $value, $message ) || $self->abort;
    $self->abort($abort);
}

sub setValue {
    my $self = shift;
    my $value = shift;
    warn "Use close to dismiss the ProgressDialog" if ($value >= $self->maximum);
    $self->value($value);
    $self->Update(value => $value);
    return 1;
}

sub setMessage {
    my $self = shift;
    my $message = shift;
    $self->message($message);
    $self->Update(message => $message);
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
