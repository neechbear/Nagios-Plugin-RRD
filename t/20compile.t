# $Id$

chdir('t') if -d 't';
use lib qw(./lib ../lib);
use Test::More tests => 2;

use_ok('Nagios::Plugin::RRD');
require_ok('Nagios::Plugin::RRD');

1;

