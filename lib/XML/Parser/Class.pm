package XML::Parser::Class;

use true;
use parent XML::Parser::Expat;

sub new {
  my($package) = shift;
  my @st;
  while (my ($symbol_table_key, $val) = each %{ *{ "$package\::" } }) {
    local *ENTRY = $val;
    push @st,[$symbol_table_key, *ENTRY{ CODE }] if defined $val and defined *ENTRY{ CODE };
  }
  my %dispatch;
  foreach (@st){
    if ($_->[0] =~ /^(?:(?'what'Start|End)_?(?'who'.*)
		    |(?'who'.*?)_?(?'what'handler))$/x){
      $dispatch{$+{what}}{$+{who}}=$_->[1];
    }
  }
  my $s = bless(XML::Parser::Expat->new,$package);
# not sure if reblessing is appropriate here... otherwise i'd have to go the AUTOLOAD-route and then I'll have to do some ugly switches in the dispatch methods.
  $s->setHandlers($s->__gen_dispatch(\%dispatch));
  return $s;
}

sub __gen_dispatch{
  die "Do you know what privacy means?" if (caller)[0] ne __PACKAGE__;
  my ($s,$dispatch) = @_;
  my %ret;
  foreach my $se (qw|Start End|) {
    if ($dispatch->{$se}) {
      if (not $s->can('transform_gi')) {
	$ret{$se} = sub {
	  if ($dispatch->{$se}{$_[1]}) {
	    $dispatch->{$se}{$_[1]}->(@_);
	  }elsif(defined $dispatch->{$se}{''}){
	    $dispatch->{$se}{''}(@_);
	  }
	}
      } else {
	foreach (keys %{$dispatch->{$se}}) {
	  if ($_ ne $s->transform_gi($_)){
	    $dispatch->{$se}{$s->transform_gi($_)} = $dispatch->{$se}{$_};
	    delete $dispatch->{$se}{$_};
	  }
	}
	$ret{$se} = sub {
	  if ($dispatch->{$se}{$s->transform_gi($_[1])}) {
	    $dispatch->{$se}{$s->transform_gi($_[1])}->(@_);
	  }elsif(defined $dispatch->{$se}{''}){
	    $dispatch->{$se}{''}(@_);
	  }
	}
      }
    }
  }
  foreach my $handler (keys %{$dispatch->{handler}}){
    $ret{$handler} = sub{$dispatch->{handler}{$handler}->($s,$_[1..$#_])}
  }
  return %ret;
}
