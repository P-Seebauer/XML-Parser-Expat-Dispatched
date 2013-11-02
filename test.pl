#!/usr/bin/env perl

use warnings;
use strict;
use 5.01;
use open qw(:encoding(utf8) :std);
use autodie ':all';

use MyParser;
foreach (0..1){
  my $p= MyParser->new(case_sensitive => $_);
  open my $fh, '<', 'test.xml';
  $p->parse($fh);
  say "$_";
}


__END__
use Data::Dumper;
say Dumper( $p);
