package XML::Parser::Expat::Dispatched;

use true;
use parent XML::Parser::Expat;
use Carp;

our $VERSION = 0.9;

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


__END__

=pod

=head1 Name

XML::Parser::Expat::Dispatched

=head1 Version

Version 0.9

=head1 Synopsis


    package MyParser;
    use parent XML::Parser::Expat::Dispatched;
    
    sub Start_tagname{
      my $self = shift;
      print $_[0], $self->original_tagname;
    }
    
    sub End_tagname{
      my $self=shift;
      print "$_[0] ended";
    }
    
    sub Char_handler{
      my ($self, $string) = @_;
      print $string;
    }
     
     sub transform_gi{
      lc $_[1];
     }


     package main;
     my $p = MyParser->new;
     $p->parse('<Tagname>tag</Tagname>');


=head1 Description

This package provides a C<new> method that produces some dispatch methods from the symbol table of your module. 
These will then be installed into the handlers of an L<XML::Parser::Expat|XML::Parser::Expat>.

=head2 API

You simply write subroutines.
Your parser will be a L<XML::Parser::Expat|XML::Parser::Expat> so consider
checking the Methods of this class if you write other methods than handler methods.
The underscore in the subroutine names is optional for all but the tranform_gi method.
The arguments your subroutine gets called with are the same as those for the handlers from
L<XML::Parser::Expat|XML::Parser::Expat>

=head3 Start_I<tagname>

Will be called when a start-tag is encountered that matches I<tagname>.
If I<tagname> is not given (when your sub is called C<Start> or C<Start_>), it works like a default-handler for start tags.

=head3 End_I<tagname>

Will be called when a end-tag is encountered that matches I<tagname>.
If I<tagname> is not given (when your sub is called C<End> or C<End_>), it works like a default-handler for end tags.

=head3 I<Handler>_handler

Installs this subroutine as a handler for L<XML::Parser::Expat|XML::Parser::Expat>. 
You can see the Handler names on L<XML::Parser::Expat>.

=head3 transform_gi (Parser, Suffix/Tagname)

This subroutine is special: you can use it to generalize the check 
between the subroutine suffix for the C<Start*> and C<End*> subroutine names
and the tagnames.

Some Examples:

    sub transform_gi{lc $_[1]}                            # case insensitive
    sub transform_gi{return $_[1]=~/:([^:]+)$/?$1: $_[1]} # try discarding the namespace

Notice that the allowed characters for perl's subroutines
and XML-Identifiers aren't the same so you might want to use the default handlers or transform_gi.


=head1 Author

Patrick Seebauer

=head1 Licence

This software is Copyright (c) 2013 by Patrick Seebauer.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
