#!/usr/bin/perl -w

use strict;
use lib qw(t/lib);
use Test::More tests => 11;

BEGIN { use_ok('File::chdir') }

use Cwd;
use File::Spec::Functions;

my $cwd = getcwd;

ok( tied $CWD,      '$CWD is fit to be tied' );

# First, let's try unlocalized $CWD.
{
    $CWD = 't';
    ::is( getcwd, catdir($cwd,'t'), 'unlocalized $CWD works' );
    ::is( $CWD,   catdir($cwd,'t'), '  $CWD set' );
}

::is( getcwd, catdir($cwd,'t'), 'unlocalized $CWD unneffected by blocks' );
::is( $CWD,   catdir($cwd,'t'), '  and still set' );


# Ok, reset ourself for the real test.
$CWD = $cwd;

{
    my $old_dir = $CWD;
    local $CWD = "t";
    ::is( $old_dir, $cwd,           '$CWD fetch works' );
    ::is( getcwd, catdir($cwd,'t'), 'localized $CWD works' );
}

::is( getcwd, $cwd,                 '  and resets automatically!' );
::is( $CWD,   $cwd,                 '  $CWD reset, too' );


chdir('t');
is( $CWD,   catdir($cwd,'t'),       'chdir() and $CWD work together' );
