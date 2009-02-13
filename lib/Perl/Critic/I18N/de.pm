##############################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
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
	  . 'Perhaps you meant to say "--verbose 3 [_1]."' =>
	  'Warnung: Das Argument "[_1]" für --verbose sieht merkwürdig aus.  '
	  . 'Vielleicht meinten Sie "--verbose 3 [_1]."',

	'Warning: --top argument "[_1]" is negative.  '
	  . 'Perhaps you meant to say "[_1] --top".' =>
	  'Warnung: Das Argument "[_1]" für --top ist negativ.  '
	  . 'Vielleicht meinten Sie "[_1] --top".',

	'Warning: --severity arg "[_1]" out of range.  '
	  . 'Severities range from "[_2]" (lowest) to '
	  . '"[_3]" (highest).' =>
'Warnung: Das Argument "[_1]" für --severity liegt außerhalb des gültigen Bereichs.  '
	  . 'Die Werte reichen von "[_2]" (niedrigster Wert) bis '
	  . '"[_3]" (höchster Wert).',

	'Nothing to critique.' => 'Es gibt nichts zu kritisieren.',
	'No such file or directory: "[_1]"' =>
	  'Es gibt weder eine Datei noch ein Verzeichnis dieses Namens: "[_1]"',
	'No perl files were found' => 'Es wurden keine Perl-Dateien gefunden',
	'No policies selected.'    => 'Keine Policys ausgewählt.',
	'Problem while critiquing "[_1]": [_2]' =>
	  'Es ist ein Problem beim Kritisieren der Datei [_1] aufgetreten: [_2]',
	'Fatal error while critiquing "[_1]": [_2]' =>
'Es ist ein schwerer Fehler beim Kritisieren der Datei [_1] aufgetreten: [_2]',
	'Fatal error while critiquing "[_1]". Unfortunately, ',
	q<$@/$EVAL_ERROR >,    ## no critic (RequireInterpolationOfMetachars)
	qq<is empty, so the reason can't be shown.> =>
'Es ist ein schwerer Fehler beim Kritisieren der Datei [_1] aufgetreten. Unglücklicherweise ist ',
	q<$@/$EVAL_ERROR >,    ## no critic (RequireInterpolationOfMetachars)
	'leer, so dass der Grund nicht mitgeteilt werden kann',
);

1;
