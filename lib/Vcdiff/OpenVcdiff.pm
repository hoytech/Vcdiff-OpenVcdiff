package Vcdiff::OpenVcdiff;

use strict;

use Vcdiff;

use Alien::OpenVcdiff;

our $VERSION = '0.100';
$VERSION = eval $VERSION;

require DynaLoader;
our @ISA = 'DynaLoader';
__PACKAGE__->bootstrap($VERSION);

1;


__END__


=head1 NAME

Vcdiff::OpenVcdiff - open-vcdiff backend for Vcdiff

=head1 SYNOPSIS

    use Vcdiff::OpenVcdiff;

    my $delta = Vcdiff::OpenVcdiff::diff($source, $target);

    ## ... send the $delta string to someone who has $source ...

    my $target2 = Vcdiff::OpenVcdiff::patch($source, $delta);

    ## $target2 is the same as $target

This module is a backend to the L<Vcdiff> module and isn't usually used directly.



=head1 DESCRIPTION

This module uses L<Alien::OpenVcdiff> which is a module that configures, builds, and installs Google's L<open-vcdiff|http://code.google.com/p/open-vcdiff/> library.

The alien package installs the C<vcdiff> binary for your convenience but this module uses the C<libvcdenc.so> and C<libvcddec.so> shared libraries so that the diffing computation is done in-process instead of forking processes.


=head1 PROS

=over

=item *

Apache licensed

=item *

open-vcdiff supports re-using "hashed dictionaries" (but this module doesn't expose that yet).

=back


=head1 CONS

=over

=item *

Even with the streaming API C<open-vcdiff> has a hard upper-limit of 2G file sizes and the default (which this module hasn't changed) is 64M so be warned.

=back


=head1 TODO

Implement the streaming API and possibly the re-usable "hashed dictionary" API.



=head1 SEE ALSO

L<Vcdiff-OpenVcdiff github repo|https://github.com/hoytech/Vcdiff-OpenVcdiff>

L<Vcdiff>

L<Alien::OpenVcdiff>

L<Official open-vcdiff website|http://code.google.com/p/open-vcdiff/>


=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2013 Doug Hoyte.

This module is licensed under the same terms as perl itself.

=cut
