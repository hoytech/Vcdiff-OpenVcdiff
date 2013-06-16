use strict;

use Test::More qw(no_plan);

use Vcdiff::OpenVcdiff;
use Vcdiff::Test;

Vcdiff::Test::streaming({ skip_streaming_source_tests => 1, });

is($Vcdiff::backend, 'Vcdiff::OpenVcdiff', 'used correct backend');
