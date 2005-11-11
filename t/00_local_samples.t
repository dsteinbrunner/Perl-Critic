#!/usr/bin/perl -w

use warnings;
use strict;
use Perl::Critic::Config;
use File::Find qw();
use Test::More tests => 1;

my @policies;
File::Find::find({wanted => \&_find_policies, no_chdir => 1},
                 'lib/Perl/Critic/Policy');

sub _find_policies {
    return if ! -f $_;
    return if ! s{\.pm \z}{}xms;

    s{lib/Perl/Critic/Policy/}{}xms;
    s{/}{::}gxms;
    push @policies, $_;
}

sub _slurp {
    my $filename = shift;
    open my $fh, '<', $filename
        or die 'no such file '.$filename;
    my $content = do { local $/; <$fh> };
    close $fh;
    return wantarray ? split /\n/, $content : $content;
}

my @expected;
my @actual;

my @none = _slurp('t/samples/perlcriticrc.none');
# Remove comments and blank lines
@expected = grep {!m/ \A [ ]* (?: \#[^\n]* )? \z /xms} @none;
@actual = map {"[-$_]"} sort {(lc $a) cmp (lc $b)} @policies;
is_deeply(\@actual, \@expected, 't/samples/perlcriticrc.none');

#my @all = _slurp('t/samples/perlcriticrc.all');
## Remove comments and blank lines
#@expected = grep {!m/ \A [ ]* (?: \#[^\n]* )? \z /xms} @all;
#@actual = map {"[$_]"} sort {(lc $a) cmp (lc $b)} 
#map {Perl::Critic::Config::_short_name(ref $_)}
#@{Perl::Critic::Config->new(-profile => q{})->policies()};
#is_deeply(\@actual, \@expected, 't/samples/perlcriticrc.all');
