package XML::Parser::Class;

use true;
use parent XML::Parser::Expat;
use Carp;

sub new {
  my($package) = shift;
  my @st;
  my %dispatch;
  while (my ($symbol_table_key, $val) = each %{ *{ "$package\::" } }) {
    local *ENTRY = $val;
    if (defined $val 
	and defined *ENTRY{ CODE }
	and $symbol_table_key =~ /^(?:(?'what'Start|End)_?(?'who'.*)
		    |(?'who'.*?)_?(?'what'handler))$/x){
      carp "the sub $symbol_table_key overrides the handler for $dispatch{$+{what}}{$+{who}}[1]"
	if exists $dispatch{$+{what}}{$+{who}};
      $dispatch{$+{what}}{$+{who}}= [*ENTRY{ CODE }, $symbol_table_key];
    }
  }
  my $s = bless(XML::Parser::Expat->new(@_),$package);
# not sure if reblessing is appropriate here... otherwise i'd have to go the AUTOLOAD-route and then I'll have to do some ugly switches in the dispatch methods.
  $s->setHandlers($s->__gen_dispatch(\%dispatch));
  return $s;
}

sub __gen_dispatch{
  my ($s,$dispatch) = @_;
  my %ret;
  foreach my $se (qw|Start End|) {
    if ($dispatch->{$se}) {
      if (not $s->can('transform_gi')) { # the alternative would be to have a generic transform_gi sub, i don't want that, because it's much slower.
	$ret{$se} = sub {
	  if ($dispatch->{$se}{$_[1]}) {
	    $dispatch->{$se}{$_[1]}[0](@_);
	  }elsif(defined $dispatch->{$se}{''}){
	    $dispatch->{$se}{''}[0](@_);
	  }
	}
      } else {
	foreach (keys %{$dispatch->{$se}}) {
	  my $new_key=$s->transform_gi($_);
	  if ($_ ne $new_key){
	    carp "$dispatch->{$se}{$new_key}[1] and $dispatch->{$se}{$_}[1] translate to the same handler"
	      if exists $dispatch->{$se}{$new_key};
	    $dispatch->{$se}{$new_key} = $dispatch->{$se}{$_};
	    delete $dispatch->{$se}{$_};
	  }
	}
	$ret{$se} = sub {
	  if ($dispatch->{$se}{$s->transform_gi($_[1])}) {
	    $dispatch->{$se}{$s->transform_gi($_[1])}[0](@_);
	  }elsif(defined $dispatch->{$se}{''}){
	    $dispatch->{$se}{''}[0](@_);
	  }
	}
      }
    }
  }
  foreach my $handler (keys %{$dispatch->{handler}}){
    $ret{$handler} = sub{$dispatch->{handler}{$handler}[0]($s,$_[1..$#_])}
  }
  return %ret;
}
