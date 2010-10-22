package Perl::Critic::Policy::Test;

use 5.006001;
use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities };
use base 'Perl::Critic::Policy';

sub default_severity { return $SEVERITY_LOWEST }
sub applies_to { return 'PPI::Token::Word' }

# Yes, I know Perl::Critic::Policy objects are not supposed to have a
# new() method. But tests are supposed to be lightweight, the
# Perl::Critic::Policy->new() method is incapable of creating a working
# policy object on its own, and I didn't want to suck in
# Perl::Critic::PolicyFactory because I was unsure where it would all
# end. Better solutions welcome. -- Tom Wyant
sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new( %args );
    $self->__set_base_parameters();
    return $self;
}

sub violates {
    my ( $self, $elem, undef ) = @_;
    return $self->violation( 'desc', 'expl', $elem );
}

sub violates_with_named_arguments {
    my ( $self, $elem, undef ) = @_;
    return $self->make_violation(
        -description    => 'desc',
        -explanation    => 'expl',
        -element        => $elem,
    );
}

1;
__END__

=head1 DESCRIPTION

diagnostic

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
