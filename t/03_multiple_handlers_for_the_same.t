use Test::More;
use 5.01;

my $warnings_installed;
BEGIN {
    eval {require Test::Warnings};
  if ($@) {
    plan skip_all => 'Test::Warnings not installed';
    exit;
  }else{
    plan (tests => 4);
    Test::Warnings->import(':all');
  }
  use_ok 't::testparser';
}

t::testparser->init(qw|Start_Test Start_test End_test Endtest|, sub{lc $_[1]});
my @w = warnings {t::testparser->new};
is(scalar @w ,2, "two warnings were issued in new");
foreach $w (@w){
  like($w,qr/(?-x:and .*?translate to the same handler at)
	   |(?-x:the sub End_?test overrides the handler for End_test)/x, $w);
}


