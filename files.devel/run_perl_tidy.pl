#!/usr/bin/perl -w

use warnings;
use strict;
use lib qw(lib);
use File::Slurp qw(read_file write_file);
use File::Find qw(find);
use File::Path qw(mkpath);
use File::Basename qw(dirname);
use File::Spec;
use Perl::Critic::Policy::CodeLayout::RequireTidyCode;

my @files = ( File::Spec->catfile('bin', 'perlcritic') );
find({wanted => sub {push @files, $_ if m/[.]pm\z/xms;}, no_chdir => 1}, 'lib');

mkpath([ map { File::Spec->catdir('files.devel', 'tdy', dirname($_)) } @files], 0, oct '755');

print 'Redo perltidy? ';
if (<STDIN> =~ m/y/xms) {
    for my $file (@files) {
        unlink File::Spec->catfile('files.devel','tdy',$file);  # failure is harmless
    }
}

FILE:
for my $file (@files) {

    CHECK:
    for (1) { # just once unless we redo

        my $filetdy = File::Spec->catfile('files.devel','tdy',$file);
        if ( ! -f $filetdy || (-M $file) < (-M $filetdy)) {
            my $result = system "perltidy -pro=t/samples/perltidyrc $file -o $filetdy";
            die 'Failed' if $result != 0;
        }

        my $orig = read_file($file);
        my $tidy = read_file($filetdy);

        {
            # fix cases that Perl::Tidy doesn't support
            my $p = Perl::Critic::Policy::CodeLayout::RequireTidyCode
                ->new(options => 'hanging_ternary');
            $tidy = $p->_apply_special_cases($tidy);
            write_file($filetdy, $tidy);
        }

        next FILE if $orig eq $tidy;
       
        print "\n *** $file ***\n\n";
        system "diff -u $file $filetdy";

        print "Apply patch to $file? ";
        if (<STDIN> =~ m/y/xms) {
            my $result = system "diff -u $file $filetdy | patch -p0";
            die 'Failed' if $result != 0;
        }
        else {
            print 'Edit? ';
            if (<STDIN> =~ m/y/xms) {
                my $exe = $ENV{EDITOR} || 'vi';
                system "$exe $file";

                redo CHECK;
            }
        }
    }
}
