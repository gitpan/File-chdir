#!/usr/bin/perl -w

use strict;
use Test::More 'no_plan';

BEGIN { use_ok('File::chdir', ':EVERYWHERE') }

package Foo;

use Cwd;
use File::Spec::Functions;

my $cwd = getcwd;

# First, let's try normal chdir()
{
    chdir('t');
    ::is( getcwd, catdir($cwd,'t'), 'void chdir still works' );

    chdir($cwd);    # reset

    if( chdir('t') ) {
        1;
    }
    else {
        ::fail('chdir() failed completely in boolean context!');
    }
    ::is( getcwd, catdir($cwd,'t'),  '  even in boolean context' );
}

::is( getcwd, catdir($cwd,'t'), '  unneffected by blocks' );


# Ok, reset ourself for the real test.
chdir($cwd) or die $!;

{
    my $old_dir = chdir("t");
    ::is( $old_dir, $cwd );
    ::is( getcwd, catdir($cwd,'t'), 'magic chdir() works' );
}

::is( getcwd, $cwd,                 '  and resets automatically!' );


{
    local $ENV{HOME} = 't';
    chdir;
    ::is( getcwd, catdir($cwd, 't'), 'magic chdir() with no args' );
    ::is( $::CWD, catdir($cwd, 't'), '  $CWD follows' );
}
