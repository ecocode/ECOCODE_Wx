package ECOCODE::ECDialog;

use Modern::Perl;

use Moose;
use MooseX::NonMoose;
use Log::Log4perl;

extends 'Wx::Dialog';
use Wx qw(wxID_ANY wxDefaultPosition wxDefaultSize wxSTAY_ON_TOP
    wxDEFAULT_DIALOG_STYLE wxID_OK wxID_CANCEL wxHORIZONTAL wxVERTICAL wxEXPAND
    wxTAB_TRAVERSAL );
use Wx::Event qw( EVT_UPDATE_UI );

has 'title' => ( is => 'rw', isa => 'Str', default => '--- ECDialog ---' );
has 'mainPanel' => ( is => 'rw', isa => 'Object' );
has 'panel'     => ( is => 'rw', isa => 'Object' );
has 'btnOK'     => ( is => 'rw', isa => 'Object' );

sub FOREIGNBUILDARGS {
    my $class  = shift;
    my %args   = @_;
    my $parent = exists $args{parent} ? $args{parent} : undef;
    my $id     = exists $args{id} ? $args{id} : wxID_ANY;
    my $title  = exists $args{title} ? $args{title} : '--- ECDialog ---';
    my $pos    = wxDefaultPosition;
    my $size   = wxDefaultSize;
    my $style  = wxDEFAULT_DIALOG_STYLE;
    my $name   = exists $args{name} ? $args{name} : "";
    return ( $parent, $id, $title, $pos, $size, $style, $name );
}

sub BUILD {
    my $self = shift;
    my $size = $self->GetClientSize();
    $self->SetTitle( $self->title );
    $self->mainPanel(
                Wx::Panel->new( $self, -1, wxDefaultPosition, wxDefaultSize ) );
    $self->setCommonWidgets;
    $self->Center;
}

sub setDialogFocus {

    # with modal Dialogs we need to call SetFocus after Dialog is shown
    my ( $self, $control ) = @_;
    EVT_UPDATE_UI(
        $self, -1,
        sub {
            $control->SetFocus();
            EVT_UPDATE_UI( $self, -1, undef );
        }
    );
}

sub setCommonWidgets {
    my $self = shift;
    my $tsz  = Wx::BoxSizer->new(wxVERTICAL);
    my $buttOK =
        Wx::Button->new( $self->mainPanel, wxID_OK, "OK", wxDefaultPosition,
                         wxDefaultSize );
    $self->btnOK($buttOK);
    my $buttCANCEL =
        Wx::Button->new( $self->mainPanel, wxID_CANCEL, "CANCEL",
                         wxDefaultPosition, wxDefaultSize );
    $self->panel(
          Wx::Panel->new( $self->mainPanel, -1, wxDefaultPosition, wxDefaultSize
          )
    );
    $tsz->Add( $self->panel, 1, wxEXPAND, 0 );
    my $buttonTsz = Wx::BoxSizer->new(wxHORIZONTAL);
    $buttonTsz->Add( $buttOK,     0, 0, 0 );
    $buttonTsz->Add( $buttCANCEL, 0, 0, 0 );
    $tsz->Add( $buttonTsz, 0, 0, 0 );
    $self->mainPanel->SetAutoLayout(1);
    $tsz->SetSizeHints( $self->mainPanel );
    $self->mainPanel->SetSizer($tsz);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
