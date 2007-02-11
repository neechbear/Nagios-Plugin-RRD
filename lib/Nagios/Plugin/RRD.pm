############################################################
#
#   $Id$
#   Nagios::Plugin::RRD - Create RRD threshold Nagios plugins
#
#   Copyright 2007 Nicola Worthington
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
############################################################

package Nagios::Plugin::RRD;
# vim:ts=4:sw=4:tw=78

use 5.6.1;
use strict;
use warnings;
use RRDs;
use Scalar::Util qw(refaddr);
use Carp qw(croak cluck carp confess);
use vars qw($VERSION $DEBUG);

$VERSION = '0.01' || sprintf('%d', q$Revision$ =~ /(\d+)/g);
$DEBUG ||= $ENV{DEBUG} ? 1 : 0;

my $objstore = {};


#
# Public methods
#

sub new {
	ref(my $class = shift) && croak 'Class name required';
	croak 'Odd number of elements passed when even was expected' if @_ % 2;

	# Conjure up an invisible object 
	my $self = bless \(my $dummy), $class;
	$objstore->{refaddr($self)} = {@_};
	my $stor = $objstore->{refaddr($self)};

	# Define what parameters are valid for this constructor
	$stor->{validkeys} = [qw(password account pin number timeout cache_ttl)];
	my $validkeys = join('|',@{$stor->{validkeys}});

	# Only accept sensible known parameters from punters
	my @invalidkeys = grep(!/^$validkeys$/,grep($_ ne 'validkeys',keys %{$stor}));
	delete $stor->{$_} for @invalidkeys;
	cluck('Unrecognised parameters passed: '.join(', ',@invalidkeys))
		if @invalidkeys && $^W;

	# Set some default values
	delete $stor->{timeout} if !defined $stor->{timeout} || $stor->{timeout} !~ /^[1-9]\d*$/;
	$stor->{timeout} ||= 15; # 15 seconds
	delete $stor->{cache_ttl} if !defined $stor->{cache_ttl} || $stor->{cache_ttl} !~ /^\d+$/;
	$stor->{cache_ttl} ||= 5; # Cache data for 5 seconds
	$stor->{'user-agent'} ||= sprintf('Mozilla/5.0 (X11; U; Linux i686; '.
				'en-US; rv:1.8.1.1) Gecko/20060601 Firefox/2.0.0.1 (%s %s)',
				__PACKAGE__, $VERSION);

	# Create LWP object
	my $ua = new LWP::UserAgent;
	$ua->env_proxy;
	$ua->agent($stor->{'user-agent'});
	$ua->timeout($stor->{timeout});
	$ua->max_size(1024 * 200); # Hard code at 200KB
	$stor->{ua} = $ua;

	DUMP('$self',$self);
	DUMP('$stor',$stor);
	return $self;
}


sub add_rule {
	my $self = shift;
	croak 'Not called as a method by parent object'
		unless ref $self && UNIVERSAL::isa($self, __PACKAGE__);

	# Retrieve our object data stor and merge
	# parameters from this method and the constructor
	my $stor = $objstore->{refaddr($self)};
	my %params = @_;
	for my $k (@{$stor->{validkeys}}) {
		$params{$k} = $stor->{$k}
			unless defined $params{$k};
	}
}


sub result {
}





#
# Private methods
#

sub DESTROY {
	my $self = shift;
	delete $objstore->{refaddr($self)};
}


sub TRACE {
	return unless $DEBUG;
	carp(shift());
}


sub DUMP {
	return unless $DEBUG;
	eval {
		require Data::Dumper;
		no warnings 'once';
		local $Data::Dumper::Indent = 2;
		local $Data::Dumper::Terse = 1;
		carp(shift().': '.Data::Dumper::Dumper(shift()));
	}
}


1;



=pod

=head1 NAME

Nagios::Plugin::RRD - Create RRD threshold Nagios plugins

=head1 SYNOPSIS

 use strict;
 use Nagios::Plugin::RRD qw();
 
 my $rrd = Nagios::Plugin::RRD->new(
         rrd => "/var/spool/rrd/host1.acme.com/mailq.rrd"
     );
 
 $rrd->add_rule(
         source => "",
         threshold => "",
         result => ""
     );
 
 my ($rtn,$msg) = $rrd->result;

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head2 add_rule

=head2 result

=head1 VERSION

$Id$

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

L<http://perlgirl.org.uk>

If you like this software, why not show your appreciation by sending the
author something nice from her
L<Amazon wishlist|http://www.amazon.co.uk/gp/registry/1VZXC59ESWYK0?sort=priority>? 
( http://www.amazon.co.uk/gp/registry/1VZXC59ESWYK0?sort=priority )

=head1 COPYRIGHT

Copyright 2007 Nicola Worthington.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut


__END__


