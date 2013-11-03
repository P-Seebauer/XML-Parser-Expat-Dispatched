use Test::More;
use 5.01;
BEGIN {
  eval {require Test::Fatal};
  if ($@) {
    plan skip_all => 'Test::Fatal not installed';
    exit;
  }else{
    plan (tests => 3);
    Test::Fatal->import('exception');
  }
  use_ok 't::testparser';
}
t::testparser->init(qw|End_handler Endtest|);
my $ex = exception {t::testparser->new};
like($ex, qr{End dispatch and End_handler declared}, "End dies");

t::testparser->reset_handlers;

t::testparser->init(qw|Start_handler Starttest|);
my $ex = exception {t::testparser->new};
like($ex, qr{Start dispatch and Start_handler declared}, "Start dies");
