use Test::More;

my (@handler_names);
BEGIN {
  @handler_names = qw| Start_foo Start End End_test Char_handler|;
  plan (tests => 2 + @handler_names);
  use_ok 't::testparser2'
}

t::testparser2->init(@handler_names);

my $p = new_ok 't::testparser2';
$p->parse(<<'EOXML');
<tests>
<foo></foo>
<bar>Whatever</bar>
<test></test>
</tests>
EOXML

foreach (@handler_names) {
  isa_ok($p->handler_arguments($_), 't::testparser2', "$_\_Caller");
}
