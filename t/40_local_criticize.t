##################################################################
#     $URL$
#    $Date$
#   $Author$
# $Revision$
##################################################################

use blib;
use strict;
use warnings;
use Test::More;

eval q{use Test::Perl::Critic (-profile => 't/samples/perlcriticrc')};
plan skip_all => 'Optional Test::Perl::Critic required to criticise code' if $@;
all_critic_ok('lib', 'bin');
