# A template for Makefile.PL.
# - Set the $PACKAGE variable to the name of your module.
# - Set $LAST_API_CHANGE to reflect the last version you changed the API 
#   of your module.
# - Fill in your dependencies in PREREQ_PM
# Alternatively, you can say the hell with this and use h2xs.

use 5.006001;

use ExtUtils::MakeMaker;

$PACKAGE = 'File::chdir';
($PACKAGE_FILE = $PACKAGE) =~ s|::|/|g;
$LAST_API_CHANGE = 0.03;

eval "require $PACKAGE";

if(!$@ && ${$PACKAGE.'::VERSION'} < $LAST_API_CHANGE) {
    print <<"CHANGE_WARN";

WARNING  WARNING  WARNING  WARNING  WARNING  WARNING  WARNING  WARNING

-----*****>>>>>     THE INTERFACE IS CHANGING     <<<<<*****----------

The next version will eliminate the chdir() override.  It's too
complicated and not worth the trouble.  Only $CWD will remain.

WARNING  WARNING  WARNING  WARNING  WARNING  WARNING  WARNING  WARNING

We'll pause for 20 seconds...

CHANGE_WARN

    sleep 20;
}

WriteMakefile(
    NAME            => $PACKAGE,
    VERSION_FROM    => "lib/$PACKAGE_FILE.pm", # finds $VERSION
    PREREQ_PM       => { Want       => 0.05,
                         Cwd        => 0,
                         File::Spec::Functions => 0,
                         Test::More => 0.17,
                       },
    'dist'          => { COMPRESS   => 'gzip -9',
                         SUFFIX     => '.gz',
                         DIST_DEFAULT   => 'all tardist',
                       },
);
