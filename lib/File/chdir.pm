package File::chdir;

use 5.006001;

use strict;
use vars qw($VERSION @ISA @EXPORT $CWD);
$VERSION = 0.02;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(chdir $CWD);

tie $CWD, 'File::chdir::CWD' or die "Can't tie \$CWD:  $!";

sub import {
    my($class, @args) = @_;

    if( grep /^:EVERYWHERE$/, @args ) {
        no warnings 'redefine';
        *CORE::GLOBAL::chdir = \&chdir;
    }
    $class->export_to_level(1, grep !/^:/, @_);
}

use Cwd;
use Want;


=head1 NAME

File::chdir - a more sensible chdir()

=head1 SYNOPSIS

  use File::chdir;
  use Cwd;
  
  chdir("/foo/bar");     # now in /foo/bar
  {
      my $old_dir = chdir("/moo/baz");  # now in /moo/baz
      ...
  }

  # still in /foo/bar!

=head1 DESCRIPTION

Perl's chdir() has the unfortunate problem of being very, very, very
global.  If any part of your program calls chdir() or if any library
you use calls chdir(), it changes the current working directory for
the B<whole> program.

This sucks.

File::chdir gives you two alternatives.  They can be safely
intermixed.

=head2 $CWD

Alternatively, you can use the $CWD variable instead of chdir().

    use File::chdir;
    $CWD = $dir;  # just like chdir($dir)!

It can be localized, and it does the right thing.

    $CWD = "/foo";      # it's /foo out here.
    {
        local $CWD = "/bar";  # /bar in here
    }
    # still /foo out here!

=head2 chdir()

File::chdir gives you a dynamically-scoped chdir().  Your chdir()
calls will have effect as long as you're in the current block.  Once
you exit, you'll rever back to the old directory.

The problem is, this requires special syntax.

    chdir($dir);

This acts just like perl's chdir().

   { my $old_dir = chdir($dir); }

This one is scoped to the current block.


=head2 EVERYWHERE!

If you want this magic chdir() to completely replace Perl's regular
chdir() across all packages, you can do this:

    use File::chdir ':EVERYWHERE';

Heh, have fun!

=cut

sub chdir (;$) {
    my($new_dir) = @_;

    # In void and boolean context we fallback to CORE::chdir()'s behavior.
    return _tracking_chdir($new_dir) if want('VOID') || want('BOOL');

    # We use getcwd() because it is taint-clean.
    my $curr_dir = Cwd::abs_path();

    _tracking_chdir($new_dir) || return 0;

    my $end = File::chdir::END->new($curr_dir);
    return $end;
}


use File::Spec::Functions qw(rel2abs);

my $Real_CWD;
sub _tracking_chdir (;$) {
    my($new_dir) = @_;

    $Real_CWD = rel2abs($new_dir) if defined $new_dir;

    return defined $new_dir ? CORE::chdir($new_dir) : CORE::chdir();
}

*CORE::GLOBAL::chdir = \&_tracking_chdir;

{
    package File::chdir::CWD;

    sub TIESCALAR { 
        $Real_CWD = Cwd::abs_path;
        bless [], $_[0];
    }
    sub FETCH { return $Real_CWD }
    sub STORE {
        return unless defined $_[1];
        File::chdir::_tracking_chdir( $_[1] );
        return $Real_CWD;
    }
}


{
    package File::chdir::END;

    use File::Spec::Functions qw(rel2abs);
    use overload '""'  => \&as_string,
                 cmp   => \&for_cmp;

    my @Stack = ();
    sub new {
        my($class, $orig_dir) = @_;
        my $self = bless {}, $class;

        $self->{orig_dir} = rel2abs($orig_dir);

        # We're *deliberately* using the stringified reference to
        # avoid making a reference and thus preventing DESTROY from
        # getting called.
        push @Stack, "$self";

        $self->{stack_idx} = $#Stack;

        return $self;
    }

    sub as_string { return $_[0]->{orig_dir} }
    sub for_cmp   { return $_[0]->{orig_dir} cmp $_[1] }
    
    sub DESTROY {
        my($self) = shift;

        # because there might be several chdir() calls in the same
        # block, they might call DESTROY out of order.  So each
        # END remembers where it was on the stack and simply throws
        # away everyone above it.
        if( $self->{stack_idx} >= $#Stack ) {
            splice @Stack, $self->{stack_idx};
            chdir($self->{orig_dir}) or 
              warn "Couldn't chdir() back to '$self->{orig_dir}'\n";
        }
    }
}


=head1 SEE ALSO

Michael G Schwern E<lt>schwern@pobox.comE<gt>

=head1 NOTES

This module requires perl 5.6.1

=head1 HISTORY

See the "local chdir" thread on p5p.

=cut

1;
