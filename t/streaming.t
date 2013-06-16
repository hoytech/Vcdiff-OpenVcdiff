use strict;

use Test::More qw(no_plan);

use Vcdiff::OpenVcdiff;
use Vcdiff::Test;

Vcdiff::Test::streaming();

is($Vcdiff::backend, 'Vcdiff::OpenVcdiff', 'used correct backend');
