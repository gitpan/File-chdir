#!/usr/bin/perl -Tw

use strict;
use lib qw(t/lib);
use Test::More tests => 6;

BEGIN { use_ok('File::chdir') }

use Cwd;

# Don't want to depend on File::Spec::Functions
sub catdir { File::Spec->catdir(@_); }

my($cwd) = getcwd =~ /(.*)/;  # detaint otherwise nothing's gonna work

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
    local $ENV{HOME} = 't';
    chdir;
    ::is( getcwd, catdir($cwd, 't'), 'chdir() with no args' );
    ::is( $CWD, catdir($cwd, 't'), '  $CWD follows' );
}

# Final chdir() back to the original or we confuse the debugger.
chdir($cwd);
