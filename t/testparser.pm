package t::testparser;
use true;
use parent XML::Parser::Class;


sub init{
  my ($package, @names) = @_;
  foreach my $name (@names){
    if ('CODE' ne ref $name){
      *{"t::testparser::$name"} = sub {
	my $s = shift;
	$s->{__testparser_handlers_visited}{$name}=[@_];
      }
    } else{
      *t::testparser::transform_gi=$name;
    }
  }
}

sub handler_arguments{
  my ($s, $name) = @_;
  return $s->{__testparser_handlers_visited}{$name};
}

sub reset_handlers{
  my $s = shift;
  delete $s->{__testparser_handlers_visited}{$_} 
    foreach keys %{$s->{__testparser_handlers_visited}};
}
