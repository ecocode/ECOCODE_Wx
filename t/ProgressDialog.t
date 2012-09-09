use Test::More ;
use Moose;

BEGIN { use_ok( 'Wx', ':everything' ); }
BEGIN { use_ok( 'ECOCODE_Wx::ECProgressDialog' ); }
BEGIN { use_ok( 'Time::HiRes', 'usleep' ); }

my $progressBar =
    ECOCODE_Wx::ECProgressDialog->new(
        parent  => undef,
        title   => 'Test Progress Bar',
        message => 'Testing the process bar',
        maximum => 100,
    );

usleep (500000);

foreach (1..100) {
    $progressBar->setValue($_);
    usleep (100000)
}

isa_ok($progressBar, 'ECOCODE_Wx::ECProgressDialog' );

done_testing();
