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
use Wx qw( wxID_YES wxEXPAND wxALL );
use ECOCODE_Wx::ECMessageDialog;
use ECOCODE_Wx::ECBrowse;
use Wx::Perl::TextValidator;

requires qw( dbc_source );    # DBIx::Class::Source table
requires qw( panel );

has 'currentDBRow' =>
    ( is => 'rw', isa => 'Maybe[DBIx::Class::Row]', trigger => \&_setCtrlRow );
has 'dataAwareControls' =>
    ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has 'dataAwareGridControls' =>   # these are _not_ auto-updated !
    ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

use aliased;
my $DATextCtrl = alias 'ECOCODE_Wx::ECDataAwareTextCtrl';
my $DACheckBox = alias 'ECOCODE_Wx::ECDataAwareCheckBox';

sub getNewBoxWithDAGrid {
    # returns a Box with a Grid and data aware info
    # currently NOT editable
    # also returns the grid to allow updating it.

    my $self = shift;
    my %args = @_;

#    return if (!$args->{resultSource});

    my $parent = $args{parent} // $self->panel;
    my $columns = $args{columns} ;
    my $rs = $args{resultSource} // undef;

    my $boxData = Wx::FlexGridSizer->new( 0, 1, 5, 5 );    # 1 column

    # create a grid type ECBrowse based on ECGrid and make it DataAware
    # Insert the grid in the $boxData

    my $browseGrid = ECOCODE_Wx::ECBrowse->new( parent=>$parent,
                                                resultSource=>$rs,
                                                columns=>$columns );

    $boxData->Add( $browseGrid, 1, wxEXPAND|wxALL, 5 );
    $boxData->AddGrowableCol(0);
    $boxData->AddGrowableRow(0);

    push @{ $self->dataAwareGridControls }, $browseGrid if ($browseGrid);

    return ($boxData,$browseGrid);
}

sub getNewBoxWithDAWidgets {
    my $self = shift;
    my $args = shift;

    return if ( !$args->{fields} );
    my $parent = $args->{parent} // $self->panel;

    my $boxData = Wx::FlexGridSizer->new( 0, 2, 5, 5 );    # 2 columns

    my @fields = @{ $args->{fields} };

    foreach my $field (@fields) {
        my $dbicColumn = $field->{dbicColumn};
        my $columnInfo = $self->dbc_source->column_info($dbicColumn);
        my $ctrl;

        # TODO ### CONTINUE HERE
        if ( $columnInfo->{is_boolean} ) {

            #create a checkbox
            $ctrl = $self->generateWidgetCheckBox(
                               { parent => $parent, field => $field, columnInfo => $columnInfo } );
            if ($ctrl) {
                $boxData->Add(undef);
                $boxData->Add($ctrl);
            }
        }
        else {
            # create a textcontrol
            $ctrl = $self->generateWidgetTextCtrl(
                               { parent => $parent, field => $field, columnInfo => $columnInfo } );
            if ($ctrl) {
                $boxData->Add( $ctrl->wxStaticText );
                $boxData->Add($ctrl);
            }
        }
        $self->dataAwareControls->{$field->{ctrl}}=$ctrl;
    }
    return $boxData;
}

sub generateWidgetCheckBox {
    my $self  = shift;
    my $args  = shift;
    my $field = $args->{field};
    return undef if ( !$field );
    my $wx_label = $field->{wx_label} // $args->{columnInfo}->{wx_label} // '';
    my $ctrl = $DACheckBox->new(
                   parent     => $args->{parent} // $self->panel,
                   label      => $wx_label,
                   width      => -1,
                   dbicColumn => $field->{dbicColumn},
                   style => ( exists( $field->{style} ) ? $field->{style} : 0 ),
    );
    return $ctrl // undef;
}

sub generateWidgetTextCtrl {
    my $self  = shift;
    my $args  = shift;
    my $field = $args->{field};
    return undef if ( !$field );
    my $wx_width = $field->{wx_width} // $args->{columnInfo}->{wx_width} // -1;
    my $wx_label = $field->{wx_label} // $args->{columnInfo}->{wx_label} // '';
    my $validator = $field->{wx_validator} // $args->{columnInfo}->{wx_validator} // undef;

    if (!$validator) { # there is no defined validator, create our own for some types
        my $colInfo = $args->{columnInfo};
        if ($colInfo->{is_numeric}) {
            $validator = qr/[0-9\.]/;
        }
    }

    my $ctrl = $DATextCtrl->new(
                   parent     => $args->{parent} // $self->panel,
                   label      => $wx_label,
                   width      => $wx_width,
                   dbicColumn => $field->{dbicColumn},
                   style => ( exists( $field->{style} ) ? $field->{style} : 0 ),
                   validator => $validator,
    );
    return $ctrl // undef;
}

sub loadRecord {    # loads record info into wx widgets
    my $self = shift;
    my $args = shift;

    my $findKey = $args->{findKey};  # findKey is the content of the primary key
    return undef if ( !$findKey );

    my $record = $self->{dbc_source}->resultset->find($findKey);

    return 0 if ( !$record );

    $self->currentDBRow($record);
    foreach my $ctrl ( values %{$self->dataAwareControls}) {
        $ctrl->setToDBICResult( result => $record );
    }
}

sub saveRecord {    #saves record data to database
    my $self = shift;
    my $args = shift;

    my $record = $self->currentDBRow();
    return 0 if ( !$record );

    # put changes in $record
    foreach my $ctrl ( values %{$self->dataAwareControls}) {
        if ( $ctrl->isChanged ) {
            $record->set_column( $ctrl->dbicColumn => $ctrl->GetValue );
        }
    }

    if ( my %changedColumns = $record->get_dirty_columns ) {
        $self->log->debug("Column $_ changed") foreach keys %changedColumns;
        $record->update_or_insert();    # should be 'eval'ed
        $record->discard_changes();  # refresh from database
        $self->_refreshControlsFromDB;
    }
    else {
        $self->log->debug("No changes to save");
    }
}

sub deleteRecord {                      # deletes the record from database
    my $self = shift;

    my $record = $self->currentDBRow();
    return 0 if ( !$record );

    return 0 if ( !$record->in_storage() );

    my @relations = $self->dbc_source->relationships();
    my @linkedRecords;
    foreach my $relation (@relations) {
        my $relationData = $self->dbc_source->relationship_info($relation);
        my $type         = $relationData->{attrs}{accessor};
        if ( $type eq 'multi' ) {
            my $count = $record->related_resultset($relation)->count();
            push @linkedRecords, "$count in relation $relation" if ($count);
        }
    }

    if (@linkedRecords) {
        my $message = join( "\n", @linkedRecords );
        ECOCODE_Wx::ECMessageDialog->new(
                                   caption => "Can't delete - relations exist:",
                                   string  => $message,
                                   type    => 'OK'
        )->ShowModal;
        return 0;
    }
    my $dialog_save =
        ECOCODE_Wx::ECMessageDialog->new( caption => "Delete record",
                                          string  => "Are you sure",
                                          type    => 'YESNO'
        );
    if ( $dialog_save->ShowModal() == wxID_YES ) {
        $record->delete();
        ECOCODE_Wx::ECMessageDialog->new( caption => "Record deleted",
                                          string  => '',
                                          type    => 'OK'
        )->ShowModal;
        $self->newRecord();
    }
}

sub _refreshControlsFromDB {
    my $self = shift;

    $_->refreshFromDB foreach ( values %{ $self->dataAwareControls } );
}

sub _setCtrlRow {    # update Rows in dataAware widgets
    my ( $self, $row, $old_row ) = @_;
    $_->currentRow($row) foreach ( values %{ $self->dataAwareControls } );
}

sub newRecord {      # create an empty record WITHOUT inserting into database
    my $self = shift;

    my $record = $self->dbc_source->resultset()->new_result( {} );
    $self->currentDBRow($record);
    $self->_refreshControlsFromDB;
    return $record;
}

no Moose::Role;

1;
