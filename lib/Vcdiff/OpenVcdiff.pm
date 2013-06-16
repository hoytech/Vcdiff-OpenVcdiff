package Vcdiff::OpenVcdiff;

use strict;

use Carp;

use Vcdiff;

use Alien::OpenVcdiff;

our $VERSION = '0.100';
$VERSION = eval $VERSION;

require XSLoader;
XSLoader::load('Vcdiff::OpenVcdiff', $VERSION);



sub diff {
  my ($source, $input, $output) = @_;

  my ($source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  $input_fileno = $output_fileno = -1;

  if (!defined $source) {
    croak "diff needs source argument";
  } elsif (ref $source eq 'GLOB') {
    ## FIXME: maybe can try an mmap() and allow this
    die "Vcdiff::OpenVcdiff::diff: source can't be a filehandle";
  } else {
    $source_str = $source;
  }

  if (!defined $input) {
    croak "diff needs target argument";
  } elsif (ref $input eq 'GLOB') {
    $input_fileno = fileno($input);
  } else {
    $input_str = $input;
  }

  if (defined $output) {
    croak "output argument to diff should be a file handle or undef"
      if ref $output ne 'GLOB';

    $output_fileno = fileno($output);
  } else {
    $output_str = '';
  }

  my $ret = _encode($source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  _check_ret($ret, 'diff');

  return $output_str if !defined $output;
}




sub patch {
  my ($source, $input, $output) = @_;

  my ($source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  $input_fileno = $output_fileno = -1;

  if (!defined $source) {
    croak "patch needs source argument";
  } elsif (ref $source eq 'GLOB') {
    ## FIXME: maybe can try an mmap() and allow this
    die "Vcdiff::OpenVcdiff::diff: source can't be a filehandle";
  } else {
    $source_str = $source;
  }

  if (!defined $input) {
    croak "patch needs delta argument";
  } elsif (ref $input eq 'GLOB') {
    $input_fileno = fileno($input);
  } else {
    $input_str = $input;
  }

  if (defined $output) {
    croak "output argument to patch should be a file handle or undef"
      if ref $output ne 'GLOB';

    $output_fileno = fileno($output);
  } else {
    $output_str = '';
  }

  my $ret = _decode($source_str, $input_fileno, $input_str, $output_fileno, $output_str);

  _check_ret($ret, 'patch');

  return $output_str if !defined $output;
}


my $exception_map = {
  1 => 'unable to initialize HashedDictionary',
  2 => 'StartEncoding error',
  3 => 'error reading from target/delta',
  4 => 'EncodeChunk error',
  5 => 'error writing to output',
  6 => 'FinishEncoding error',
  7 => 'DecodeChunk error',
  8 => 'FinishDecoding error',
  9 => 'unknown C++ exception',
};

sub _check_ret {
  my ($ret, $func) = @_;

  return unless $ret;

  my $exception = $exception_map->{$ret};

  croak "error in Vcdiff::OpenVcdiff::$func: $exception" if $exception;

  croak "unknown error in Vcdiff::OpenVcdiff::$func ($ret)";
}



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
