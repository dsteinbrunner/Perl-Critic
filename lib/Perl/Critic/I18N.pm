##############################################################################
#      $URL: $
#     $Date: $
#   $Author: $
# $Revision: $
##############################################################################
package Perl::Critic::I18N;

use Locale::Maketext;
use base qw(Locale::Maketext Exporter);

# We export one function by default. This is our translator.
our @EXPORT=qw(__);

# Get 'handle' for the language we ought to translate to.
our $language_handle = Perl::Critic::I18N->get_handle() || die "Unable to get language handle";

# Our translation function just calls maketext() for the specific language.
sub __ { $language_handle->maketext(@_) };

# Taken from Locale::Maketexts man page: If maketext fails, we want to see who called it.
$Carp::Verbose = 1;

# I decree that this project's first language is English.

%Lexicon = (
	'_AUTO' => 1,

    # The following lines are taken from the sample module File::Findgrep.
    
	# That means that lookup failures can't happen -- if we get as far
	#  as looking for something in this lexicon, and we don't find it,
	#  then automagically set $Lexicon{$key} = $key, before possibly
	#  compiling it.

	# The exception is keys that start with "_" -- they aren't auto-makeable.

);

1;

