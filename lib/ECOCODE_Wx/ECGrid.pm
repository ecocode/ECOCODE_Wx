package ECOCODE_Wx::ECGrid;

=head1 NAME

    ECGrid - Moose class around a customized Wx Grid

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

    Copyright 2012-2014 Erik Colson

=head1 AUTHOR

    Erik Colson

=cut

use feature "switch";

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;

extends 'Wx::Grid';

use Wx qw ( WXK_UP WXK_DOWN WXK_RETURN WXK_TAB wxDefaultPosition wxDefaultSize
            wxWANTS_CHARS wxID_ANY);
use Wx::Event
    qw ( EVT_GRID_EDITOR_CREATED EVT_KEY_DOWN EVT_SET_FOCUS EVT_KILL_FOCUS
       EVT_GRID_SELECT_CELL EVT_ACTIVATE EVT_CHILD_FOCUS);

has 'nameForLog' => ( is => 'rw', isa => 'Str', default => 'ECGrid' );
has 'log' => ( is => 'rw', isa => 'Object' );
has 'bgColourNotEdit' => ( is => 'rw', isa => 'Object' );
has 'attrNotEdit'     => ( is => 'rw', isa => 'Object' );
has 'bgColourEdit'    => ( is => 'rw', isa => 'Object' );
has 'attrEdit'        => ( is => 'rw', isa => 'Object' );
has 'bgColourSelect'  => ( is => 'rw', isa => 'Object' );
has 'attrNotCurLine'  => ( is => 'rw', isa => 'Object' );
has 'attrCurLine'     => ( is => 'rw', isa => 'Object' );
has 'previousControl' => ( is => 'rw', isa => 'Object' );
has 'nextControl'     => ( is => 'rw', isa => 'Object' );
has 'currentHighlightedRow' =>
    ( is => 'rw', isa => 'Maybe[Int]', default => undef );

sub close {
    my $self = shift;
    $self->Destroy();
}

sub FOREIGNBUILDARGS {
    my $class  = shift;
    my %args   = @_;
    my $parent = exists $args{parent} ? $args{parent} : undef;
    my $id     = exists $args{id} ? $args{id} : wxID_ANY;
    my $pos    = wxDefaultPosition;
    my $size   = wxDefaultSize;
    my $style  = wxWANTS_CHARS;
    my $name   = exists $args{name} ? $args{name} : "";
    return ( $parent, $id, $pos, $size, $style, $name );
}

sub BUILD {
    my $self = shift;
    my $args = shift;
    $self->log(Log::Log4perl->get_logger($self->nameForLog));
    $self->log->debug($self->nameForLog.": Parent should be defined") if (!$args->{parent});

    $self->setDefaults;
    $self->defineEventArrows;
}

sub setPreviousControl {
    my ( $self, $previousControl ) = @_;
    $self->previousControl($previousControl);
}

sub setNextControl {
    my ( $self, $nextControl ) = @_;
    $self->nextControl($nextControl);
}

sub setDefaults { ### LOTS OF THESE SHOULD BE CLASS VARIABLES !!!
    my $self = shift;

    $self->bgColourNotEdit( Wx::Colour->new( 230, 230, 230 ) );
    $self->attrNotEdit( Wx::GridCellAttr->new() );
    $self->attrNotEdit->SetReadOnly(1);

    $self->bgColourEdit( Wx::Colour->new( 255, 255, 255 ) );
    $self->attrEdit( Wx::GridCellAttr->new() );
    $self->attrEdit->SetReadOnly(0);

    $self->bgColourSelect( Wx::Colour->new( 255, 255, 255 ) );

    $self->attrNotCurLine( Wx::GridCellAttr->new() );
    $self->attrCurLine( Wx::GridCellAttr->new() );

    $self->attrNotCurLine->SetBackgroundColour( $self->bgColourNotEdit );
    $self->attrCurLine->SetBackgroundColour( $self->bgColourSelect );

    $self->currentHighlightedRow(undef);    # no row highlighted
}

sub setColumnNotEdit {
    my ( $self, $column ) = @_;
    $self->SetColAttr( $column, $self->attrNotEdit );
}

sub setColumnEdit {
    my ( $self, $column ) = @_;
    $self->SetColAttr( $column, $self->attrEdit );
}

sub defineEventArrows {
    my $self = shift;

    EVT_KEY_DOWN(
        $self,
        sub {
            my ( $this, $event ) = @_;    # $this holds the current cell !
                  $self->log->debug($self->nameForLog.": EVT_KEY_DOWN GRID generated");
            my $key = $event->GetKeyCode();
            $self->BeginBatch();
          SWITCH:
            for ($key) {
                if ( $_ == WXK_UP ) {

                    $self->log->debug($self->nameForLog.":  UP pushed");
                    if ( $self->GetGridCursorRow() > 0 ) {
                        $self->MoveCursorUp(0);
                        $event->Skip(0);    # remove the event from the queue
                    }
                    else {
                        $event->Skip(0);
                    }
                    last SWITCH;
                };
                if ( $_ == WXK_DOWN ) {

                    $self->log->debug($self->nameForLog.":  DOWN pushed");
                    if ( $self->GetGridCursorRow()
                         < $self->GetNumberRows() - 1 )
                    {
                        $self->MoveCursorDown(0);
                        $event->Skip(0);    # remove the event from the queue
                    }
                    else {
                        $event->Skip(0);
                    }
                    last SWITCH;
                };
                if ( $_ == WXK_RETURN ) {

                    $self->log->debug($self->nameForLog.":  ENTER pushed");
                    $this->HideCellEditControl();
                    if ( $self->GetGridCursorRow()
                         < $self->GetNumberRows() - 1 )
                    {
                        $self->MoveCursorDown(0);
                    }
                    else {
                    }
                    $event->Skip(0);
                    last SWITCH;
                };
                if ( $_ == WXK_TAB ) {
                    my $keyhandled = 0;
                    $self->log->debug($self->nameForLog.":  TAB pushed");
                    if ( $event->ShiftDown() ) {    # Shift-Tab
                        $self->log->debug($self->nameForLog." Move to previous control");
                        $self->Navigate(0x0000);
                        $keyhandled=1;
                    }
                    else {                          # Tab
                        $self->log->debug($self->nameForLog." Move to next control");
                        $self->Navigate(0x0001);
                        $keyhandled=1;
                    }
                    $event->Skip(0) if $keyhandled;
                    last SWITCH;
                };
                { $event->Skip(1) } # default
            }
            $self->EndBatch();
        }
    );

    EVT_SET_FOCUS(
        $self,
        sub {
            my ( $this, $event ) = @_;

            $self->log->debug($self->nameForLog.": EVT_SET_FOCUS");
            $self->highlightRow( $self->GetGridCursorRow() );
            $event->Skip(1);
        }
    );

    EVT_KILL_FOCUS(
        # BUG
        # ON MACOSX this event only occurs when switching to another app. It is not enough to set focus to another widget !
        $self,
        sub {
            my ( $this, $event ) = @_;
            $self->log->debug($self->nameForLog.": EVT_KILL_FOCUS");
            if ( $this->IsCellEditControlEnabled() ) {

                $self->log->debug($self->nameForLog.": GRID KNOWS A CELLEDITOR IS ENABLED");
            }
            else {

                $self->log->debug($self->nameForLog.": GRID THINKS THERE IS NO CELLEDITOR ENABLED");
                $self->unHighlightRow();    #  $this->GetGridCursorRow()
            }
            $event->Skip(1);
        }
    );

    EVT_ACTIVATE( # NOT USED
        $self,
        sub {
            my ( $this, $event) = @_;
            $self->log->debug($self->nameForLog.": EVT_ACTIVATE");
            $event->Skip(1);
        }
    );

    EVT_CHILD_FOCUS( # NOT USED
        $self,
        sub {
            my ( $this, $event) = @_;
            $self->log->debug($self->nameForLog.": EVT_CHILD_FOCUS");
            $event->Skip(1);
        }
    );

    EVT_GRID_SELECT_CELL(
        $self,
        sub {
            my ( $this, $event) = @_;
            my $gridRow = $event->GetRow();
            $self->log->debug($self->nameForLog.": EVT_GRID_SELECT_CELL called on row $gridRow");
            $this->highlightRow( $gridRow );
            $event->Skip(1);
        }
    );
}

sub highlightRow {
    my ( $self, $newRow ) = @_;
    $self->BeginBatch();
    if ( defined($newRow) ) {
        $self->SetRowAttr( $newRow, $self->attrCurLine );

       $self->log->debug($self->nameForLog.": SHOWING Row $newRow") ;
    }

# is this part working ? unhighlight the current highlighted row if it is not the same
    if ( defined( $self->currentHighlightedRow )
         && ( $self->currentHighlightedRow != $newRow )
        )    # be sure we don't unhl the row we need highlight!
    {

        $self->log->debug( $self->nameForLog.": AUTOHIDE row " . $self->currentHighlightedRow );
        $self->unHighlightRow( $self->currentHighlightedRow );
    }
    $self->currentHighlightedRow($newRow);
    $self->EndBatch();
    $self->Refresh();
}

sub unHighlightRow {
    my ( $self, $row ) = @_;

    $row = ( defined( $self->currentHighlightedRow )
             ? $self->currentHighlightedRow
             : $self->GetGridCursorRow() )
        if ( !defined($row) );

    $self->log->debug($self->nameForLog.": HIDING Row $row");
    $self->SetRowAttr( $row, $self->attrNotCurLine );
    $self->currentHighlightedRow(undef);
    $self->Refresh();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
