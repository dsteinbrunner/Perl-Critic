#######################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
########################################################################

package Perl::Critic::Policy::CodeLayout::RequireTidyCode;

use strict;
use warnings;
use English qw(-no_match_vars);
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.13';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

my $desc = q{Code is not tidy};
my $expl = [33];

#----------------------------------------------------------------------------

sub priority   { return $PRIORITY_LOWEST }
sub applies_to { return 'PPI::Document' }

#----------------------------------------------------------------------------

sub new {
    my ( $class, %config ) = @_;
    my $self = bless {}, $class;
    $self->{_perltidyrc} = undef;
    $self->{_extras}     = {};

    #Set configuration, if defined.
    if ( defined $config{perltidyrc} ) {
        $self->{_perltidyrc} = $config{perltidyrc};
    }
    if ( defined $config{options} ) {
        $self->{_extras}
          = { map { $_ => 1 } split m/\s+/xms, $config{options} };
    }

    return $self;
}

sub violates {
    my ( $self, $elem, $doc ) = @_;

    # If Perl::Tidy is missing, silently pass this test
    eval { require Perl::Tidy; };
    return if $EVAL_ERROR;

    my $source = "$doc";
    my $dest   = $EMPTY;
    my $stderr = $EMPTY;

    # Remove the post-shebang magic line from ExtUtils::MakeMaker
    # It looks something like this:
    #     eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    #         if 0; # not running under some shell
    $source =~ s/\n                                    # blank line
                 eval [ ]+ \'exec [ ]+                 # eval 'exec 
                   [^ ]+ [ ]+ (?:[\w\-]+[ ]+)*         # perl -S 
                   \$0 [ ]+ \$\{1\+\"\$@\"\}\'[ ]* \n  # $0 ${1+"$@"}' 
                 [ ]* if [^;\n]+ ; [^\n]* \n           #  if 0; #comment
                //xms;

    {

        # Temporarily clear any @ARGV to workaround a weird conflict
        # where Perl::Tidy disallows the "source" flag if there's anything
        # on @ARGV
        local @ARGV = ();

        Perl::Tidy::perltidy( source      => \$source,
                              destination => \$dest,
                              stderr      => \$stderr,
                              ( $self->{_perltidyrc}
                                ? ( perltidyrc => $self->{_perltidyrc} )
                                : ()
                              ),
        );
    }

    if ($stderr) {

        # Looks like perltidy had problems
        $desc = q{perltidy had errors!!};
    }

    $dest = $self->_apply_special_cases($dest);

    if ( $source ne $dest ) {
        return Perl::Critic::Violation->new( $desc, $expl, [ 0, 0 ] );
    }

    return;    #ok!
}

sub _apply_special_cases {
    my $self = shift;
    my $code = shift;

    if ( $self->{_extras}->{hanging_ternary} ) {

        # Find code like this:
        #     my $result = $foo eq 'bar' ? 1
        #                : $foo eq 'baz' ? 2
        #                : 3;
        # and change it to this:
        #     my $result = $foo eq 'bar' ? 1
        #                : $foo eq 'baz' ? 2
        #                :                 3;
        # Note that this regex only looks at the last two of those lines

        $code =~ s/ ^ ( [ ]+ : ) ( [^:?\n;]+ \? [ ]* ) ( [^:?\n;]+ \n )
                        [ ]+ :                  [ ]*   ( [^:?\n;]+ ;  )
                  / $1 .                $2  . $3 .
                    $1 . (q{ } x length $2) . $4 /gexms;
    }

    return $code;
}

1;

__END__

=pod

=head1 NAME

Perl::Critic::Policy::CodeLayout::RequireTidyCode

=head1 DESCRIPTION

Conway does make specific recommendations for whitespace and
curly-braces in your code, but the most important thing is to adopt a
consistent layout, regardless of the specifics.  And the easiest way
to do that is to use L<Perl::Tidy>.  This policy will complain if
you're code hasn't been run through Perl::Tidy.

=head1 CONSTRUCTOR

Perl::Tidy is highly configurable.  If you choose not to use the
default configuration, you can either use a F<$HOME/.perltidyrc> file,
or specify a configuration filename in your F<.perlcriticrc> file like
in the example below.

  [CodeLayout::RequireTidyCode]
  perltidyrc = /home/chris/perltidyrc
  options = hanging_ternary

Despite its configurability, Perl::Tidy lacks a few of the formatting
options recommended by Conway.  This module offers limited support for
post-processing the Perl::Tidy output to correct these limitations.
Currently there's just one new feature, but more may be added in the
future.  These options are specified as a space-separated list on the
C<options> key in your F<.perlcriticrc> file like in the example
above.  Here are the current options:

=over 8

=item hanging_ternary

Conway advocated a cascading if-elsif-else style like in this example:

  #Load profile in various ways
  my $user_prefs
    = $ref_type eq 'SCALAR' ?  _load_from_string( $profile )
    : $ref_type eq 'ARRAY'  ?  _load_from_array( $profile )
    : $ref_type eq 'HASH'   ?  _load_from_hash( $profile )
    :                          _load_from_file( $profile );

but Perl::Tidy doesn't support proper indentation of that last line.
The C<hanging_ternary> option fixes that line to match the one before
it.

=back

=head1 NOTES

Since L<Perl::Tidy> is not widely deployed, this is the only policy in
the L<Perl::Critic> distribution that is not enabled by default.  To
enable it, put this line in your F<.perlcriticrc> file:

 [CodeLayout::RequireTidyCode]

=head1 SEE ALSO

L<Perl::Tidy>


=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
