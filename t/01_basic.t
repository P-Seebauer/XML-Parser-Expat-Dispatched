use threads;
use Test::More;

my (@good_names, @bad_names);
BEGIN {
@good_names = qw| Start_foo  Startbar End End_test Char_handler|;
@bad_names  = qw| start_test EndBar|;
plan (tests => @good_names+@bad_names+2);
use_ok 't::testparser'
}

t::testparser->init(@good_names, @bad_names);

my $p = new_ok 't::testparser';
$p->parse(<<'EOXML');
<tests>
<foo></foo>
<bar></bar>
<test></test>
</tests>
EOXML

foreach (@good_names) {
  ok('ARRAY' eq ref $p->handler_arguments($_), "$_ was called");
}
foreach (@bad_names) {
  ok('ARRAY' ne ref $p->handler_arguments($_), "$_ wasn't called");
}
