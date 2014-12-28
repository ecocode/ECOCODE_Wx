package ECOCODE_Wx::ECBrowse;

=head1 NAME

    ECBrowse - Grid which shows records of database

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

extends 'ECOCODE_Wx::ECGrid';

has 'resultSet' => ( is      => 'rw',
                     isa     => 'Maybe[DBIx::Class::ResultSet]',
                     trigger => \&_changeRS,
                 );
has 'curResultSource' => ( is => 'rw',
                           isa => 'Maybe[DBIx::Class::ResultSource]', );
has '+nameForLog' => ( is => 'rw', isa => 'Str', default => 'ECBrowse' );
has 'columns' => ( is => 'rw', isa => 'ArrayRef', );

sub BUILD {
    my $self = shift;
    my $args = shift;

    my @columns = @{$self->columns};
    my $rs = $args->{resultSource};
    $self->CreateGrid(0,scalar @columns);
    $self->HideRowLabels;
    foreach (0.. $#columns) {
        my $colname = $columns[$_];
        my $colinfo = $rs->column_info($colname);
        $self->SetColLabelValue($_, $colinfo->{wx_label} // $columns[$_]);
        $self->SetColSize($_,$colinfo->{wx_width}) if ($colinfo->{wx_width});
        $self->setColumnNotEdit($_);
        # TODO: set width to values from resultsource
    }
    return $self;
}

sub _changeRS {
    my $self = shift;

    $self->log->debug($self->nameForLog.": RS triggered") if $self->log;

    my $rs = $self->resultSet;
    return if !$rs;
    $self->BeginBatch;

    # delete grid data rows
    $self->DeleteRows(0,$self->GetNumberRows,undef);

    my $rsSource = $rs->result_source();
    $self->curResultSource($rsSource);

    $self->log->debug($self->nameForLog.": ".$rs->count." records") if $self->log;
    my $x = 0; # rowcount
    while (my $faktuurRow = $rs->next) {
        $self->addOneRow;
        foreach my $col (0..$#{$self->columns}) {
            $self->SetCellValue($x,$col,$faktuurRow->get_column(${$self->columns}[$col]));
        }
        $x++;
    }
    $self->log->debug($self->nameForLog.": ".$self->GetNumberRows." rows in grid") if $self->log;
    $self->EndBatch;
    $self->Refresh;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
