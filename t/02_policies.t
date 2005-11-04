##################################################################
#     $URL$
#    $Date$
#   $Author$
# $Revision$
##################################################################

use strict;
use warnings;
use Test::More tests => 168;
use Perl::Critic::Config;
use Perl::Critic;

# common P::C testing tools
use lib qw(t/tlib);
use PerlCriticTestUtils qw(pcritique);
PerlCriticTestUtils::block_perlcriticrc();

my $code ;
my $policy;
my %config;

#----------------------------------------------------------------

$code = <<'END_PERL';
substr( $foo, 2, 1 ) = 'XYZ';
END_PERL

$policy = 'BuiltinFunctions::ProhibitLvalueSubstr';
is( pcritique($policy, \$code), 1, 'lvalue' );

#----------------------------------------------------------------

$code = <<'END_PERL';
substr $foo, 2, 1, 'XYZ';
END_PERL

$policy = 'BuiltinFunctions::ProhibitLvalueSubstr';
isnt( pcritique($policy, \$code), 1, '4 arg substr' );

#----------------------------------------------------------------

$code = <<'END_PERL';
$bar = substr( $foo, 2, 1 );
END_PERL

$policy = 'BuiltinFunctions::ProhibitLvalueSubstr';
isnt( pcritique($policy, \$code), 1, 'rvalue' );

#----------------------------------------------------------------

$code = <<'END_PERL';
%bar = (
    'foobar'    => substr( $foo, 2, 1 ),
    );
END_PERL

$policy = 'BuiltinFunctions::ProhibitLvalueSubstr';
isnt( pcritique($policy, \$code), 1, 'hash rvalue' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select( undef, undef, undef, 0.25 );
END_PERL

$policy = 'BuiltinFunctions::ProhibitSleepViaSelect';
is( pcritique($policy, \$code), 1, 'sleep, as list' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select( undef, undef, undef, $time );
END_PERL

$policy = 'BuiltinFunctions::ProhibitSleepViaSelect';
is( pcritique($policy, \$code), 1, 'sleep, as list w/var' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select undef, undef, undef, 0.25;
END_PERL

$policy = 'BuiltinFunctions::ProhibitSleepViaSelect';
is( pcritique($policy, \$code), 1, 'sleep, as built-in' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select $vec, undef, undef, 0.25;
END_PERL

$policy = 'BuiltinFunctions::ProhibitSleepViaSelect';
isnt( pcritique($policy, \$code), 1, 'select on read' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select undef, $vec, undef, 0.25;
END_PERL

$policy = 'BuiltinFunctions::ProhibitSleepViaSelect';
isnt( pcritique($policy, \$code), 1, 'select on write' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select undef, undef, $vec, 0.25;
END_PERL

$policy = 'BuiltinFunctions::ProhibitSleepViaSelect';
isnt( pcritique($policy, \$code), 1, 'select on error' );

#----------------------------------------------------------------

$code = <<'END_PERL';
eval "$some_code";
END_PERL

$policy = 'BuiltinFunctions::ProhibitStringyEval';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
eval { some_code() };
eval( {some_code() } );
eval();
END_PERL

$policy = 'BuiltinFunctions::ProhibitStringyEval';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$hash1{eval} = 1;
%hash2 = (eval => 1);
END_PERL

$policy = 'BuiltinFunctions::ProhibitStringyEval';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
grep $_ eq 'foo', @list;
@matches = grep $_ eq 'foo', @list;
END_PERL

$policy = 'BuiltinFunctions::RequireBlockGrep';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
grep {$_ eq 'foo'}  @list;
@matches = grep {$_ eq 'foo'}  @list;
grep( {$_ eq 'foo'}  @list );
@matches = grep( {$_ eq 'foo'}  @list )
grep();
@matches = grep();
END_PERL

$policy = 'BuiltinFunctions::RequireBlockGrep';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$hash1{grep} = 1;
%hash2 = (grep => 1);
END_PERL

$policy = 'BuiltinFunctions::RequireBlockGrep';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
map $_++, @list;
@foo = map $_++, @list;
END_PERL

$policy = 'BuiltinFunctions::RequireBlockMap';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
map {$_++}   @list;
@foo = map {$_++}   @list;
map( {$_++}   @list );
@foo = map( {$_++}   @list );
map();
@foo = map();
END_PERL

$policy = 'BuiltinFunctions::RequireBlockMap';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$hash1{map} = 1;
%hash2 = (map => 1);
END_PERL

$policy = 'BuiltinFunctions::RequireBlockMap';
is( pcritique($policy, \$code), 0, $policy);

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
@files = <*.pl>;
END_PERL

$policy = 'BuiltinFunctions::RequireGlobFunction';
is( pcritique($policy, \$code), 1, 'glob via <...>' );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
foreach my $file (<*.pl>) {
    print $file;
}
END_PERL

$policy = 'BuiltinFunctions::RequireGlobFunction';
is( pcritique($policy, \$code), 1, 'glob via <...> in foreach' );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
@files = (<*.pl>, <*.pm>);
END_PERL

$policy = 'BuiltinFunctions::RequireGlobFunction';
is( pcritique($policy, \$code), 1, 'multiple globs via <...>' );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
while (<$fh>) {
    print $_;
}
END_PERL

$policy = 'BuiltinFunctions::RequireGlobFunction';
isnt( pcritique($policy, \$code), 1, 'I/O' );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
my $self = bless {};
my $self = bless [];

#Critic doesn't catch these,
#cuz they parse funny
#my $self = bless( {} );
#my $self = bless( [] );

END_PERL

$policy = 'ClassHierarchies::ProhibitOneArgBless';
is( pcritique($policy, \$code), 2, $policy );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
my $self = bless {}, 'foo';
my $self = bless( {}, 'foo' );
my $self = bless [], 'foo';
my $self = bless( [], 'foo' );
END_PERL

$policy = 'ClassHierarchies::ProhibitOneArgBless';
is( pcritique($policy, \$code), 0, $policy );

#-----------------------------------------------------------------------------

$code = <<"END_PERL";
#This will be interpolated!

sub my_sub {
\tfor(1){
\t\tdo_something();
\t}
}

\t\t\t;

END_PERL

$policy = 'CodeLayout::ProhibitHardTabs';
is( pcritique($policy, \$code), 0, $policy );

#-----------------------------------------------------------------------------

$code = <<"END_PERL";
#This will be interpolated!
print "\t  \t  foobar  \t";
END_PERL

$policy = 'CodeLayout::ProhibitHardTabs';
is( pcritique($policy, \$code), 1, $policy );

#-----------------------------------------------------------------------------

$code = <<"END_PERL";
##This will be interpolated!

sub my_sub {
\tfor(1){
\t\tdo_something();
\t}
}

END_PERL

%config = (allow_leading_tabs => 0);
$policy = 'CodeLayout::ProhibitHardTabs';
is( pcritique($policy, \$code, \%config), 3, $policy );

#-----------------------------------------------------------------------------

$code = <<"END_PERL";
##This will be interpolated!

sub my_sub {
;\tfor(1){
\t\tdo_something();
;\t}
}

END_PERL

%config = (allow_leading_tabs => 0);
$policy = 'CodeLayout::ProhibitHardTabs';
is( pcritique($policy, \$code, \%config), 3, $policy );

#----------------------------------------------------------------

$code = <<'END_PERL';
open ($foo, $bar);
open($foo, $bar);
uc();
lc();
END_PERL

$policy = 'CodeLayout::ProhibitParensWithBuiltins';
is( pcritique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
open $foo, $bar;
uc $foo;
lc $foo;
my $foo;
my ($foo, $bar);
our ($foo, $bar);
local ($foo $bar);
return ($foo, $bar);
return ();
my_subroutine($foo $bar);
END_PERL

$policy = 'CodeLayout::ProhibitParensWithBuiltins';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $obj = SomeClass->new();
$obj->open();
$obj->close();
$obj->prototype();
$obj->delete();
END_PERL

$policy = 'CodeLayout::ProhibitParensWithBuiltins';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@list = ($foo, $bar, $baz);
@list = some_function($foo, $bar, $baz);
@list = ($baz);
@list = ();

@list = ($baz
);

@list = ($baz
	);

END_PERL

$policy = 'CodeLayout::RequireTrailingCommas';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@list = ($foo, 
	 $bar, 
	 $baz);

@list = ($foo, 
	 $bar, 
	 $baz
	);

@list = ($foo, 
	 $bar, 
	 $baz
);


END_PERL

$policy = 'CodeLayout::RequireTrailingCommas';
is( pcritique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@list = ($foo, 
	 $bar, 
	 $baz,);

@list = ($foo, 
	 $bar, 
	 $baz,
);

@list = ($foo, 
	 $bar, 
	 $baz,
	);

END_PERL

$policy = 'CodeLayout::RequireTrailingCommas';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
for($i=0; $i<=$max; $i++){
  do_something();
}
END_PERL

$policy = 'ControlStructures::ProhibitCStyleForLoops';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
for(@list){
  do_something();
}

for my $element (@list){
  do_something();
}

foreach my $element (@list){
  do_something();
}

do_something() for @list;
END_PERL

$policy = 'ControlStructures::ProhibitCStyleForLoops';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
do_something() if $condition;
do_something() while $condition;
do_something() until $condition;
do_something() unless $condition;
do_something() for @list;
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( pcritique($policy, \$code), 5, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
do_something() if $condition;
do_something() while $condition;
do_something() until $condition;
do_something() unless $condition;
do_something() for @list;
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
%config = (allow => 'if while until unless for');
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if($condition){ do_something() } 
while($condition){ do_something() }
until($condition){ do_something() }
unless($condition){ do_something() }
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
%config = (allow => 'if while until unless for');
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#PPI versions < 1.03 had problems with this
for my $element (@list){ do_something() }
for (@list){ do_something_else() }

END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Carp;

while ($condition) {
    next if $condition;
    last if $condition; 
    redo if $condition;
    return if $condition;
    goto HELL if $condition;
}

die 'message' if $condition;
die if $condition;

warn 'message' if $condition;
warn if $condition;

carp 'message' if $condition;
carp if $condition;

croak 'message' if $condition;
croak if $condition;

cluck 'message' if $condition;
cluck if $condition;

confess 'message' if $condition;
confess if $condition;

END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my %hash;
$hash{if} = 1;
$hash{unless} = 1;
$hash{until} = 1;
$hash{while} = 1;
$hash{for} = 1;
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my %hash = (if => 1, unless => 1, until => 1, while => 1, for => 1);
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
elsif ($condition3){
  $baz;
}
elsif ($condition4){
  $barf;
}
else {
  $nuts;
}
END_PERL

$policy = 'ControlStructures::ProhibitCascadingIfElse';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
elsif ($condition3){
  $bar;
}
else {
  $nuts;
}

if ($condition1){
  $foo;
}
else {
  $nuts;
}

if ($condition1){
  $foo;
}
END_PERL

$policy = 'ControlStructures::ProhibitCascadingIfElse';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
elsif ($condition3){
  $baz;
}
else {
  $nuts;
}
END_PERL

%config = (max_elsif => 1);
$policy = 'ControlStructures::ProhibitCascadingIfElse';
is( pcritique($policy, \$code, \%config), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
until($condition){
  do_something();
}
END_PERL

$policy = 'ControlStructures::ProhibitUntilBlocks';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
while(! $condition){
  do_something();
}

do_something() until $condition
END_PERL

$policy = 'ControlStructures::ProhibitUntilBlocks';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
unless($condition){
  do_something();
}
END_PERL

$policy = 'ControlStructures::ProhibitUnlessBlocks';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if(! $condition){
  do_something();
}

do_something() unless $condition
END_PERL

$policy = 'ControlStructures::ProhibitUnlessBlocks';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#just a comment
$foo = "bar";
$baz = qq{nuts};
END_PERL

$policy = 'Miscellanea::RequireRcsKeywords';
is( pcritique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
# $Revision$
# $Source$
# $Date$
END_PERL

$policy = 'Miscellanea::RequireRcsKeywords';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
'$Revision$'
'$Source: foo/bar $'
'$Date$'
END_PERL

$policy = 'Miscellanea::RequireRcsKeywords';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
q{$Revision$}
q{$Source: foo/bar $}
q{$Date$}
END_PERL

$policy = 'Miscellanea::RequireRcsKeywords';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
q{$Revision$}
q{$Author$}
q{$Id: whatever $}
END_PERL

%config = (keywords => 'Revision Author Id');
$policy = 'Miscellanea::RequireRcsKeywords';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#nothing here!
END_PERL

%config = (keywords => 'Author Id');
$policy = 'Miscellanea::RequireRcsKeywords';
is( pcritique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
package bar;
package nuts;
$some_code = undef;
END_PERL

$policy = 'Modules::ProhibitMultiplePackages';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
$some_code = undef;
END_PERL

$policy = 'Modules::ProhibitMultiplePackages';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
require 'Exporter';
require 'My/Module.pl';
use 'SomeModule';
use "OtherModule.pm";
no "Module";
no "Module.pm";
END_PERL

$policy = 'Modules::RequireBarewordIncludes';
is( pcritique($policy, \$code), 6, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
require MyModule;
use MyModule;
no MyModule;
use strict;
END_PERL

$policy = 'Modules::RequireBarewordIncludes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
package foo;
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Some::Module;
package foo;
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Some::Module;
print 'whatever';
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
use strict;
$foo = $bar;
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#!/usr/bin/perl
$foo = $bar;
package foo;
END_PERL

%config = (exempt_scripts => 1); 
$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#!/usr/bin/perl
use strict;
use warnings;
my $foo = 42;

END_PERL

%config = (exempt_scripts => 1);
$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code, \%config), 0, $policy);


#----------------------------------------------------------------

$code = <<'END_PERL';
#!/usr/bin/perl
package foo;
$foo = $bar;
END_PERL

%config = (exempt_scripts => 1); 
$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Evil::Module qw(bad stuff);
use Super::Evil::Module;
END_PERL

$policy = 'Modules::ProhibitSpecificModules';
%config = (modules => 'Evil::Module Super::Evil::Module');
is( pcritique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Good::Module;
END_PERL

$policy = 'Modules::ProhibitSpecificModules';
%config = (modules => 'Evil::Module Super::Evil::Module');
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#Nothing!
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our $VERSION = 1.0;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our ($VERSION) = 1.0;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$Package::VERSION = 1.0;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use vars '$VERSION';
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use vars qw($VERSION);
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $VERSION;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our $Version;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
__END__
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
__DATA__
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
# The end
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1; # final true value
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
0;
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
sub foo {}
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
END {}
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
'Larry';
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $string =~ m{pattern}x;
my $string =~ m{pattern}gimx;
my $string =~ m{pattern}gixs;
my $string =~ m{pattern}xgms;

my $string =~ m/pattern/x;
my $string =~ m/pattern/gimx;
my $string =~ m/pattern/gixs;
my $string =~ m/pattern/xgms;

my $string =~ /pattern/x;
my $string =~ /pattern/gimx;
my $string =~ /pattern/gixs;
my $string =~ /pattern/xgms;

my $string =~ s/pattern/foo/x;
my $string =~ s/pattern/foo/gimx;
my $string =~ s/pattern/foo/gixs;
my $string =~ s/pattern/foo/xgms;
END_PERL

$policy = 'RegularExpressions::RequireExtendedFormatting';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $string =~ m{pattern};
my $string =~ m{pattern}gim;
my $string =~ m{pattern}gis;
my $string =~ m{pattern}gms;

my $string =~ m/pattern/;
my $string =~ m/pattern/gim;
my $string =~ m/pattern/gis;
my $string =~ m/pattern/gms;

my $string =~ /pattern/;
my $string =~ /pattern/gim;
my $string =~ /pattern/gis;
my $string =~ /pattern/gms;

my $string =~ s/pattern/foo/;
my $string =~ s/pattern/foo/gim;
my $string =~ s/pattern/foo/gis;
my $string =~ s/pattern/foo/gms;

END_PERL

$policy = 'RegularExpressions::RequireExtendedFormatting';
is( pcritique($policy, \$code), 16, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@out = `some_command`;
@out = qx{some_command};
END_PERL

$policy = 'InputOutput::ProhibitBacktickOperators';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
open FH, '>', $some_file;
open FH, '>', $some_file or die;
open(FH, '>', $some_file);
open(FH, '>', $some_file) or die;

END_PERL

$policy = 'InputOutput::ProhibitBarewordFileHandles';
is( pcritique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
open $fh, '>', $some_file;
open $fh, '>', $some_file or die;
open($fh, '>', $some_file);
open($fh, '>', $some_file) or die;

open my $fh, '>', $some_file;
open my $fh, '>', $some_file or die;
open(my $fh, '>', $some_file);
open(my $fh, '>', $some_file) or die;

END_PERL

$policy = 'InputOutput::ProhibitBarewordFileHandles';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
select( $fh );
END_PERL

$policy = 'InputOutput::ProhibitOneArgSelect';
is( pcritique($policy, \$code), 1, '1 arg; variable, w/parens' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select $fh;
END_PERL

$policy = 'InputOutput::ProhibitOneArgSelect';
is( pcritique($policy, \$code), 1, '1 arg; variable, as built-in' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select( STDERR );
END_PERL

$policy = 'InputOutput::ProhibitOneArgSelect';
is( pcritique($policy, \$code), 1, '1 arg; fh, w/parens' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select STDERR;
END_PERL

$policy = 'InputOutput::ProhibitOneArgSelect';
is( pcritique($policy, \$code), 1, '1 arg; fh, as built-in' );

#----------------------------------------------------------------

$code = <<'END_PERL';
select( undef, undef, undef, 0.25 );
END_PERL

$policy = 'InputOutput::ProhibitOneArgSelect';
isnt( pcritique($policy, \$code), 1, '4 args' );

#----------------------------------------------------------------

$code = <<'END_PERL';

open $fh, ">$output";
open($fh, ">$output");
open($fh, ">$output") or die;

open my $fh, ">$output";
open(my $fh, ">$output");
open(my $fh, ">$output") or die;

open FH, ">$output";
open(FH, ">$output");
open(FH, ">$output") or die;

#This are tricky because the Critic can't
#tell where the expression really ends
open FH, ">$output" or die;
open $fh, ">$output" or die;
open my $fh, ">$output" or die;

END_PERL

$policy = 'InputOutput::ProhibitTwoArgOpen';
is( pcritique($policy, \$code), 12, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
open $fh, '>', $output";
open($fh, '>', $output");
open($fh, '>', $output") or die;

open my $fh, '>', $output";
open(my $fh, '>', $output");
open(my $fh, '>', $output") or die;

open FH, '>', $output";
open(FH, '>', $output");
open(FH, '>', $output") or die;

#This are tricky because the Critic can't
#tell where the expression really ends
open $fh, '>', $output" or die;
open my $fh, '>', $output" or die;
open FH, '>', $output" or die;

END_PERL

$policy = 'InputOutput::ProhibitTwoArgOpen';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print "this is literal";
print qq{this is literal};
END_PERL

$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------
$code = <<'END_PERL';
print 'this is literal';
print q{this is literal};
END_PERL

$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;
END_PERL

%config = (allow => 'qq( qq{ qq[ qq/'); 
$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;
END_PERL

%config = (allow => 'qq( qq{'); 
$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( pcritique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;
END_PERL

%config = (allow => '() {}'); #Testing odd config
$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( pcritique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;
END_PERL

%config = (allow => 'qq() qq{}'); #Testing odd config
$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( pcritique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print 'this is not $literal';
print q{this is not $literal};
print 'this is not literal\n';
print q{this is not literal\n};
END_PERL

$policy = 'ValuesAndExpressions::RequireInterpolationOfMetachars';
is( pcritique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print "this is not $literal";
print qq{this is not $literal};
print "this is not literal\n";
print qq{this is not literal\n};
END_PERL

$policy = 'ValuesAndExpressions::RequireInterpolationOfMetachars';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 01;
$var = 010;
$var = 001;
$var = 0010;
$var = 0.12;
$var = 00.001;
$var = -01;
$var = -010;
$var = -001;
$var = -0010;
$var = -0.12;
$var = -00.001;
$var = +01;
$var = +010;
$var = +001;
$var = +0010;
$var = +0.12;
$var = +00.001;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitLeadingZeros';
is( pcritique($policy, \$code), 18, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 0;
$var = 0.;
$var = 10;
$var = 0.0;
$var = 10.0;
$var = -0;
$var = -0.;
$var = -10;
$var = -0.0;
$var = -10.0;
$var = +0;
$var = +0.;
$var = +10;
$var = +0.0;
$var = +10.0;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitLeadingZeros';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 1234_567;
$var = 1234_567.;
$var = 1234_567.890;
$var = -1234_567.8901;
$var = -1234_567;
$var = -1234_567.;
$var = -1234_567.890;
$var = -1234_567.8901;
$var = +1234_567;
$var = +1234_567.;
$var = +1234_567.890;
$var = +1234_567.8901;

END_PERL

$policy = 'ValuesAndExpressions::RequireNumberSeparators';
is( pcritique($policy, \$code), 12, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 12;
$var = 1234;
$var = 1_234;
$var = 1_234.01;
$var = 1_234_567;
$var = 1_234_567.;
$var = 1_234_567.890_123;
$var = -1_234;
$var = -1_234.01;
$var = -1_234_567;
$var = -1_234_567.;
$var = -1_234_567.890_123;
$var = +1_234;
$var = +1_234.01;
$var = +1_234_567;
$var = +1_234_567.;
$var = +1_234_567.890_123;
END_PERL

$policy = 'ValuesAndExpressions::RequireNumberSeparators';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 1000001;
$var = 1000000.01;
$var = 1000_000.01;
$var = 10000_000.01;
$var = -1000001;
$var = -1234567;
$var = -1000000.01;
$var = -1000_000.01;
$var = -10000_000.01;
END_PERL

%config = (min_value => 1_000_000);
$policy = 'ValuesAndExpressions::RequireNumberSeparators';
is( pcritique($policy, \$code, \%config), 9, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 999999;
$var = 123456;
$var = 100000.01;
$var = 10_000.01;
$var = 100_000.01;
$var = -999999;
$var = -123456;
$var = -100000.01;
$var = -10_000.01;
$var = -100_000.01;
END_PERL

%config = (min_value => 1_000_000);
$policy = 'ValuesAndExpressions::RequireNumberSeparators';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@list = ('foo', 'bar', 'baz');

@list = ('foo',
	 'bar',
	 'baz');

END_PERL

$policy = 'CodeLayout::ProhibitQuotedWordLists';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@list = ('foo', 'bar', 'bee baz');
@list = ('foo, 'bar');
@list = ($foo, 'bar', 'baz');
%hash = ('foo' => 'bar', 'fo' => 'fum');
my_function('foo', 'bar', 'fudge');
foreach ('foo', 'bar', 'nuts'){ do_something($_) }
END_PERL

$policy = 'CodeLayout::ProhibitQuotedWordLists';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@list = ('foo', 'bar, 'baz');
END_PERL

%config = (min_elements => 4);
$policy = 'CodeLayout::ProhibitQuotedWordLists';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@list = ('foo', 'bar', 'baz', 'nuts');
END_PERL

%config = (min_elements => 4);
$policy = 'CodeLayout::ProhibitQuotedWordLists';
is( pcritique($policy, \$code, \%config), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $fooBAR;
my ($fooBAR) = 'nuts';
local $FooBar;
our ($FooBAR);
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseVars';
is( pcritique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my ($foobar, $fooBAR);
my (%foobar, @fooBAR, $foo);
local ($foobar, $fooBAR);
local (%foobar, @fooBAR, $foo);
our ($foobar, $fooBAR);
our (%foobar, @fooBAR, $foo);
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseVars';
is( pcritique($policy, \$code), 6, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $foo_BAR;
my $FOO_BAR;
my $foo_bar;
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseVars';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my ($foo_BAR, $BAR_FOO);
my ($foo_BAR, $BAR_FOO) = q(this, that);
our (%FOO_BAR, @BAR_FOO);
local ($FOO_BAR, %BAR_foo) = @_;
my ($foo_bar, $foo);
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseVars';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub fooBAR {}
sub FooBar {}
sub Foo_Bar {}
sub FOObar {}
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseSubs';
is( pcritique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo_BAR {}
sub foo_bar {}
sub FOO_bar {}
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseSubs';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub test_sub1 {
	$foo = shift;
	return undef;
}

sub test_sub2 {
	shift || return undef;
}

sub test_sub3 {
	return undef if $bar;
}

END_PERL

$policy = 'Subroutines::ProhibitExplicitReturnUndef';
is( pcritique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub test_sub1 {
	$foo = shift;
	return;
}

sub test_sub2 {
	shift || return;
}

sub test_sub3 {
	return if $bar;
}

END_PERL

$policy = 'Subroutines::ProhibitExplicitReturnUndef';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub my_sub1 ($@) {}
sub my_sub2 (@@) {}
END_PERL

$policy = 'Subroutines::ProhibitSubroutinePrototypes';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub my_sub1 {}
sub my_sub1 {}
END_PERL

$policy = 'Subroutines::ProhibitSubroutinePrototypes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub open {}
sub map {}
sub eval {}
END_PERL

$policy = 'Subroutines::ProhibitBuiltinHomonyms';
is( pcritique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub my_open {}
sub my_map {}
sub eval2 {}
END_PERL

$policy = 'Subroutines::ProhibitBuiltinHomonyms';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub import {}
END_PERL

$policy = 'Subroutines::ProhibitBuiltinHomonyms';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { return; }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { return {some => [qw(complicated data)], q{ } => /structure/}; }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { if (1) { return; } else { return; } }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { if (1) { return; } elsif (2) { return; } else { return; } }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

TODO:
{
local $TODO = 'we are not yet detecting ternaries';
$code = <<'END_PERL';
sub foo { 1 ? return : 2 ? return : return; }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 0, $policy);
}

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { return 1 ? 1 : 2 ? 2 : 3; }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { 'Club sandwich'; }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

# This one IS valid to a human or an optimizer, but it's too rare and
# too hard to detect so we disallow it

$code = <<'END_PERL';
sub foo { while (1==1) { return; } }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo { if (1) { $foo = 'bar'; } else { return; } }
END_PERL

$policy = 'Subroutines::RequireFinalReturn';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
use warnings;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageWarnings';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageWarnings';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use warnings;
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageWarnings';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
use strict;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageStricture';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageStricture';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Module;
use strict;
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageStricture';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use constant FOO => 42;
use constant BAR => 24;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitConstantPragma';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $FOO = 42;
local BAR = 24;
our $NUTS = 16;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitConstantPragma';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = "";
$var = ''
$var = '     ';
$var = "     ";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitEmptyQuotes';
is( pcritique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = qq{};
$var = q{}
$var = qq{     };
$var = q{     };
END_PERL

$policy = 'ValuesAndExpressions::ProhibitEmptyQuotes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = qq{this};
$var = q{that}
$var = qq{the};
$var = q{other};
$var = "this";
$var = 'that';
$var = 'the'; 
$var = "other";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitEmptyQuotes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = "!";
$var = '!';
$var = '!!';
$var = "||";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitNoisyQuotes';
is( pcritique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = q{'};
$var = q{"};
$var = q{!!};
$var = q{||};
$var = "!!!";
$var = '!!!';
$var = 'a';
$var = "a";
$var = '1';
$var = "1";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitNoisyQuotes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = '(';
$var = ')';
$var = '{';
$var = '}';
$var = '[';
$var = ']';

$var = '{(';
$var = ')}';
$var = '[{';
$var = '[}';
$var = '[(';
$var = '])';

$var = "(";
$var = ")";
$var = "{";
$var = "}";
$var = "[";
$var = "]";

$var = "{(";
$var = ")]";
$var = "({";
$var = "}]";
$var = "{[";
$var = "]}";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitNoisyQuotes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<END_QUOTE;
Four score and seven years ago...
END_QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireQuotedHeredocTerminator';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<'END_QUOTE';
Four score and seven years ago...
END_QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireQuotedHeredocTerminator';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<"END_QUOTE";
Four score and seven years ago...
END_QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireQuotedHeredocTerminator';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<"endquote";
Four score and seven years ago...
endquote
END_PERL

$policy = 'ValuesAndExpressions::RequireUpperCaseHeredocTerminator';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<endquote;
Four score and seven years ago...
endquote
END_PERL

$policy = 'ValuesAndExpressions::RequireUpperCaseHeredocTerminator';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<"QUOTE";
Four score and seven years ago...
QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireUpperCaseHeredocTerminator';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
local $foo = $bar;
local $/ = undef;
local $| = 1;
local ($foo, $bar) = ();
local ($/) = undef;
local ($RS, $>) = ();
local ($foo, %SIG);
END_PERL

$policy = 'Variables::ProhibitLocalVars';
is( pcritique($policy, \$code), 7, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
local ($RS);
local $INPUT_RECORD_SEPARATOR;
local $PROGRAM_NAME;
local ($EVAL_ERROR, $OS_ERROR);
my  $var1 = 'foo';
our $var2 = 'bar';
local $SIG{HUP} \&handler;
local $INC{$module} = $path;
END_PERL

$policy = 'Variables::ProhibitLocalVars';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our $var1 = 'foo';
our (%var2, %var3) = 'foo';
our (%VAR4, $var5) = ();
$Package::foo;
@Package::list = ('nuts');
%Package::hash = ('nuts');
$::foo = $bar;
@::foo = ($bar);
%::foo = ();
use vars qw($FOO $BAR);
END_PERL

$policy = 'Variables::ProhibitPackageVars';
is( pcritique($policy, \$code), 10, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our $VAR1 = 'foo';
our (%VAR2, %VAR3) = ();
our $VERSION = '1.0';
our @EXPORT = qw(some symbols);
$Package::VERSION = '1.2';
%Package::VAR = ('nuts');
@Package::EXPORT = ();
$::VERSION = '1.2';
%::VAR = ('nuts');
@::EXPORT = ();
&Package::my_sub();
&::my_sub();
END_PERL

$policy = 'Variables::ProhibitPackageVars';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $var1 = 'foo';
my %var2 = 'foo';
my ($foo, $bar) = ();
END_PERL

$policy = 'Variables::ProhibitPackageVars';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$/ = undef;
$| = 1;
$> = 3;
END_PERL

$policy = 'Variables::ProhibitPunctuationVars';
is( pcritique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$RS = undef;
$INPUT_RECORD_SEPARATOR = "\n";
$OUTPUT_AUTOFLUSH = 1;
print $foo, $baz;
END_PERL

$policy = 'Variables::ProhibitPunctuationVars';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$string =~ /((foo)bar)/;
$foobar = $1;
$foo = $2;
$3;
$stat = stat(_);
@list = @_;
my $line = $_;
END_PERL

$policy = 'Variables::ProhibitPunctuationVars';
is( pcritique($policy, \$code), 0, $policy);

