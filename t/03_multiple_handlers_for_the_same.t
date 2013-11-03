use Test::More;

my (@bad_names);
BEGIN {
@bad_names  = qw|Start_Test Start_test|;
plan (tests =>2);
use_ok 't::testparser';
}

t::testparser->init(@bad_names);
my $p;
eval{
  $p= t::testparser->new;
};
ok (defined $!, "warn two subs for the same");
