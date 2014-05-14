package ECOCODE_Wx::ECRoleDataAwareContainer;

=head1 NAME

    ECDataAwareContainer - adds data aware to ECFrame

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

use strict;
use warnings;

use Moose::Role;
use Log::Log4perl;
use Wx;

requires qw( dbc_source ); # DBIx::Class::Source table
requires qw( panel );

has 'dataAwareControls' =>
    ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

use aliased;
my $DATextCtrl = alias 'ECOCODE_Wx::ECDataAwareTextCtrl';
my $DACheckBox = alias 'ECOCODE_Wx::ECDataAwareCheckBox';

sub getNewBoxWithDAWidgets {
    my $self = shift;
    my $args = shift;

    return if (!$args->{fields});

    # my $boxData = $args->{containerBox} if ($args->{containerBox});
    my $boxData = Wx::FlexGridSizer->new(undef,2,5,5); # 2 columns

    my @fields = @{$args->{fields}};

    foreach my $field ( @fields ) {
        my $dbicColumn = $field->{dbicColumn};
        my $columnInfo = $self->dbc_source->column_info($dbicColumn);
        my $ctrl;

        # TODO ### CONTINUE HERE
        if ($columnInfo->{is_boolean}) {
            #create a checkbox
            $ctrl = $self->generateWidgetCheckBox({field=>$field,columnInfo=>$columnInfo});
            if ($ctrl) {
                $boxData->Add( undef );
                $boxData->Add( $ctrl );
            }
        } else {
            # create a textcontrol
            $ctrl = $self->generateWidgetTextCtrl({field=>$field,columnInfo=>$columnInfo});
            if ($ctrl) {
                $boxData->Add( $ctrl->wxStaticText );
                $boxData->Add($ctrl);
            }
        }
        push @{ $self->dataAwareControls }, $ctrl if ($ctrl);
    }
    return $boxData;
}

sub generateWidgetCheckBox {
    my $self = shift;
    my $args = shift;
    my $field = $args->{field};
    return undef if (!$field);
    my $wx_label = $field->{wx_label} // $args->{columnInfo}->{wx_label} // '';
    my $ctrl = $DACheckBox->new(
        parent     => $self->panel,
        label      => $wx_label,
        width      => -1,
        dbicColumn => $field->{dbicColumn},
        style => ( exists( $field->{style} ) ? $field->{style} : 0 ),
    );
    return $ctrl // undef;
}

sub generateWidgetTextCtrl {
    my $self = shift;
    my $args = shift;
    my $field = $args->{field};
    return undef if (!$field);
    my $wx_width = $field->{wx_width} // $args->{columnInfo}->{wx_width} // -1;
    my $wx_label = $field->{wx_label} // $args->{columnInfo}->{wx_label} // '';
    my $ctrl = $DATextCtrl->new(
        parent     => $self->panel,
        label      => $wx_label,
        width      => $wx_width,
        dbicColumn => $field->{dbicColumn},
        style => ( exists( $field->{style} ) ? $field->{style} : 0 ),
    );
    return $ctrl // undef;
}

sub loadRecord { # loads record info into wx widgets
    my $self = shift;
    my $args = shift;

    my $findKey = $args->{findKey}; # findKey is the content of the primary key
    return undef if (!$findKey);

    my $record = $self->{dbc_source}->resultset->find($findKey);
    if ($record) {
        foreach my $ctrl ( @{ $self->dataAwareControls } ) {
            $ctrl->setToDBICResult( result => $record );
        }
    }
}

no Moose::Role;

1;