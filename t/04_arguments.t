use Test::More;
use strict;
use warnings;

my %expected_args;
BEGIN{
  %expected_args = 
    (End => [['foo'],['foo'],['bar'],['test'],['tests']],
    );
  plan(tests =>(2 + keys %expected_args));
  use_ok ('t::testparser');
}
t::testparser->init(keys %expected_args, sub{lc $_[1]});
my $p = new_ok 't::testparser';
$p->parse(<<'EOXML');
<tests>
<foo arg="hallo" ></foo>
<foo />
<bar></bar>
<test></test>
</tests>
EOXML


foreach (keys %expected_args){
  is_deeply($expected_args{$_},$p->handler_arguments($_), "arguments for $_ as expected");
}



