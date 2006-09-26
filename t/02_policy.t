#######################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
########################################################################

use strict;
use warnings;
use English qw(-no_match_vars);
use Test::More tests => 13;


#-------------------------------------------------------------------------
# Perl::Critic::Policy is an abstract class, so it can't be instantiated
# directly.  So we test it be declaring a test class that inherits from it.

package PolicyTest;
use base 'Perl::Critic::Policy';

#-------------------------------------------------------------------------

package main;

my $p = PolicyTest->new();
isa_ok($p, 'PolicyTest');

eval { $p->violates(); };
ok($EVAL_ERROR, 'abstract violates');

#Test default application...
is($p->applies_to(), 'PPI::Element', 'applies_to');

#Test default severity...
is( $p->default_severity(), 1, 'default_severity');
is( $p->get_severity(), 1, 'get_severity' );

#Change severity level...
$p->set_severity(3);

#Test severity again...
is( $p->default_severity(), 1 ); #Still the same
is( $p->get_severity(), 3 );     #Should have new value

#Test default theme...
is_deeply($p->default_theme(), ['pc'], 'default_theme');
is_deeply($p->get_theme(), ['pc'], 'get_theme');

#Change theme
$p->set_theme( ['foo'] );

#Test theme again...
is_deeply( $p->default_theme(), ['pc'] );   #Still the same
is_deeply( $p->get_theme(), ['foo'] );  #Should have new value

#Append theme
$p->add_theme( [qw(bar baz) ] );

#Test theme again...
is_deeply( $p->default_theme(), ['pc'] );               #Still the same
is_deeply( $p->get_theme(), [ qw(foo bar baz) ] );  #Should have new value
