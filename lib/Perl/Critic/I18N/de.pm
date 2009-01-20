##############################################################################
#      $URL: $
#     $Date: $
#   $Author: $
# $Revision: $
##############################################################################
package Perl::Critic::I18N::de;

use strict;
use warnings;

use base qw(Perl::Critic::I18N);

our %Lexicon = (
	'_AUTO' => 1,

	'Warning: Cannot use -noprofile with -profile option.' =>
'Warnung: Die Optionen --profile und --noprofile können nicht zusammen verwendet werden.',

	'Warning: --verbose arg "[_1]" looks odd.  '
	  . 'Perhaps you meant to say "--verbose 3 [_1]."'
	  => 'Warnung: Das Argument "[_1]" für --verbose sieht merkwürdig aus.  '
	  . 'Vielleicht meinten Sie "--verbose 3 [_1]."'

);

1;                                                        
