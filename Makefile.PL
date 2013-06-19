use strict;

use ExtUtils::MakeMaker;


use Alien::OpenVcdiff;
 
my $openvcdiff = Alien::OpenVcdiff->new;
 
my $libs = $openvcdiff->libs;
my $cflags = $openvcdiff->cflags;

if ($cflags =~ m{^-I\S*google/?$}) {
  $cflags .= '/../';
} else {
  die "Unexpected value from Alien::OpenVcdiff::cflags: $cflags";
}


my %args = (
    NAME              => 'Vcdiff::OpenVcdiff',
    VERSION_FROM      => 'lib/Vcdiff/OpenVcdiff.pm',
    XSOPT             => '-C++',
    CC                => 'g++',
    CCFLAGS           => $cflags,
    LIBS              => $libs,
    PREREQ_PM => {
      'Alien::OpenVcdiff' => 0,
      'Vcdiff' => '0.500',
      'Sys::Mmap' => 0,
      'Guard' => 0,
    },
    OBJECT            => 'Interface.o',
    LICENSE           => 'perl',
    dist => {
      PREOP => 'perldoc -uT $(VERSION_FROM) > README.pod; pod2text README.pod > $(DISTVNAME)/README',
    },
);


my $eummv = eval ($ExtUtils::MakeMaker::VERSION);
if ($eummv >= 6.45) {
    $args{META_MERGE} = {
        resources => {
            repository => 'git://github.com/hoytech/Vcdiff-OpenVcdiff.git',
            bugtracker => 'https://github.com/hoytech/Vcdiff-OpenVcdiff/issues',
        },
    };
}

WriteMakefile(%args);
