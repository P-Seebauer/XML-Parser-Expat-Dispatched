package XML::Parser::Class;

use true;
use parent XML::Parser::Expat;

sub new {
  my($package) = shift;
  my %options = @_;
  my $p;
  my $s = $p = XML::Parser::Expat->new;

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

  $p->setHandlers(__gen_dispatch(\%options,\%dispatch, $s));
  return bless($s,$package);
}

sub __gen_dispatch{
  die "Do you know what privacy means?" if (caller)[0] ne __PACKAGE__;
  my ($opt, $dispatch,$s) = @_;
  my %ret;
  foreach my $se (qw|Start End|){
    if ($dispatch->{$se}){
      if ($opt->{case_sensitive} ){
	$ret{$se} = sub {
	  if ($dispatch->{$se}{$_[1]}) {
	    $dispatch->{$se}{$_[1]}->($s,@_[1..$#_]);
	  }}
      }else{
	$dispatch->{$se}{(lc)} = $dispatch->{$se}{$_} 
	  foreach keys %{$dispatch->{$se}};
	$ret{$se} = sub {if ($dispatch->{$se}{lc $_[1]}) {
	  $dispatch->{$se}{lc $_[1]}->($s,@_[1..$#_]);
	}}
      }
    }
  }
  foreach my $handler (keys %{$dispatch->{handler}}){
    $ret{$handler} = sub{$dispatch->{handler}{$handler}->($s,$_[1..$#_])}
  }
  return %ret;
}

sub setHandlers{...} # no dumb ideas allowed
