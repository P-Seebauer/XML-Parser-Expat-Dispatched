use Test::More;
use strict;
use warnings;

my %expected_args;
BEGIN{
  %expected_args =
    (End             => [['bar'],['test'],['tests']],
     End_foo         => [(['foo'])x2],
     Start_Foo       => [['foo', 'arg', 'hallo'], ['foo']],
     Char_handler    => [(["\n"])x4,["What a test"], ["\n"]],
     Proc_handler    => [['perl', 'aha']],
     Comment_handler => [['Comment']],
     Default_handler => [['<?xml version="1.0"?>'], ["\n"],["\n"]],
    );
  plan(tests =>(2 + keys %expected_args));
  use_ok ('t::testparser');
}
t::testparser->init(keys %expected_args, sub{lc $_[1]});
my $p = new_ok 't::testparser';
$p->parse(*DATA);

foreach (sort keys %expected_args){
  is_deeply($p->handler_arguments($_),$expected_args{$_},
	    "arguments for $_ as expected");
}

__DATA__
<?xml version="1.0"?>
<tests><?perl aha?>
<foo arg="hallo" ></foo>
<foo /><!--Comment-->
<bar></bar>
<test>What a test</test>
</tests>
