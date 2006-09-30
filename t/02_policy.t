#!perl

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
is_deeply( [$p->default_theme()], [], 'default_theme');
is_deeply( [$p->get_theme()], [], 'get_theme');

#Change theme
$p->set_theme( qw(c b a) ); #unsorted

#Test theme again...
is_deeply( [$p->default_theme()], [] ); #Still the same
is_deeply( [$p->get_theme()], [qw(a b c)] );  #Should have new value (sorted)

#Append theme
$p->add_theme( qw(f e d) ); #unsorted

#Test theme again...
is_deeply( [$p->default_theme()], [] ); #Still the same
is_deeply( [$p->get_theme()], [ qw(a b c d e f) ] );  #Should have new value (sorted)
