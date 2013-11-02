package MyParser;

use true;
use lib 'lib';
use parent XML::Parser::Class;
use 5.01;


my $in_test = 0;
sub StartTest{
  my $s = shift;
  print $s->original_string;
  $in_test++;
}

sub EndTest{
  my $s = shift;
  say $s->original_string;
  $in_test--;
}


sub Char_handler{
  my $s = shift;
  if ($in_test > 0){
    print $s->original_string;
  }
}

sub End_tests{
  my $s= shift;
  $s->frobnicate;
}

sub frobnicate{
  my $s = shift;
  say $s;
}
