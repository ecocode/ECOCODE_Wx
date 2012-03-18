package ECOCODE::ECMessageDialog;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;

extends 'Wx::MessageDialog';
use Wx qw(wxID_ANY wxCENTRE wxYES_NO wxCANCEL wxDefaultPosition);
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
