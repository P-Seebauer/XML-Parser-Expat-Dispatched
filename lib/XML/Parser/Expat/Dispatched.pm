package XML::Parser::Expat::Dispatched;

use true;
use parent XML::Parser::Expat;
use Carp;

sub new {
  my($package) = shift;
  my %dispatch;
  while (my ($symbol_table_key, $val) = each %{ *{ "$package\::" } }) {
    local *ENTRY = $val;
    if (defined $val 
	and defined *ENTRY{ CODE }
	and $symbol_table_key =~ /^(?:(?'who'.*?)_?(?'what'handler)
				  |(?'what'Start|End)_?(?'who'.*))$/x){
      carp "the sub $symbol_table_key overrides the handler for $dispatch{$+{what}}{$+{who}}[1]"
	if exists $dispatch{$+{what}}{$+{who}};
      $dispatch{$+{what}}{$+{who}}= [*ENTRY{ CODE }, $symbol_table_key];
    }
  }
  my $s = bless(XML::Parser::Expat->new(@_),$package);
  foreach (qw(Start End)) {
    croak "$_ dispatch and $_\_handler declared"
      if $dispatch{$_} and exists $dispatch{handler}{$_};
  }
  $s->setHandlers($s->__gen_dispatch(\%dispatch));
  return $s;
}

sub __gen_dispatch{
  my ($s,$dispatch) = @_;
  my %ret;
  foreach my $se (qw|Start End|) {
    if ($dispatch->{$se}) {
      if (not $s->can('transform_gi')) {
	# the alternative would be to have a generic transform_gi sub, i don't want that, because it's much slower.
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
  $ret{$_} = $dispatch->{handler}{$_}[0] foreach keys %{$dispatch->{handler}};
  return %ret;
}
