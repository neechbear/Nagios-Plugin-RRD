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
use Nagios::Plugin::Functions qw(nagios_exit nagios_die check_messages);
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
	$stor->{validkeys} = [qw(rrd die_on_unknown)];
	my $validkeys = join('|',@{$stor->{validkeys}});

	# Only accept sensible known parameters from punters
	my @invalidkeys = grep(!/^$validkeys$/,grep($_ ne 'validkeys',keys %{$stor}));
	delete $stor->{$_} for @invalidkeys;
	cluck('Unrecognised parameters passed: '.join(', ',@invalidkeys))
		if @invalidkeys && $^W;

	# Set default values
	$stor->{die_on_unknown} ||= 0;

	# Create empty result sets
	$stor->{unknown}  = [];
	$stor->{critical} = [];
	$stor->{warning}  = [];
	$stor->{ok}       = [];

	# If the RRD file does not exist
	$stor->{rrd} ||= '';
	unless (-e $stor->{rrd}) {
		my $msg = "RRD file '$stor->{rrd}' does not exist";
		push @{$stor->{unknown}}, $msg;
		nagios_die($msg) if $stor->{die_on_unknwon};
	}

	DUMP('$self',$self);
	DUMP('$stor',$stor);
	return $self;
}


sub add_rule {
	my $self = shift;
	croak 'Not called as a method by parent object'
		unless ref $self && UNIVERSAL::isa($self, __PACKAGE__);
	my $stor = $objstore->{refaddr($self)};

}


sub sources {
	my $self = shift;
	croak 'Not called as a method by parent object'
		unless ref $self && UNIVERSAL::isa($self, __PACKAGE__);
	my $stor = $objstore->{refaddr($self)};

}


sub last {
	my $self = shift;
	croak 'Not called as a method by parent object'
		unless ref $self && UNIVERSAL::isa($self, __PACKAGE__);
	my $stor = $objstore->{refaddr($self)};

}


sub result {
	my $self = shift;
	croak 'Not called as a method by parent object'
		unless ref $self && UNIVERSAL::isa($self, __PACKAGE__);
	my $stor = $objstore->{refaddr($self)};

	return check_messages(
			'critical' => $stor->{critical},
			'warning'  => $stor->{warning},
			'ok'       => $stor->{ok},
			'join'     => ' ',
		);
}





#
# Private methods
#

sub _read_rrd {

}





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

=head2 last

=head2 sources

=head2 add_rule

=head2 result

=head1 SEE ALSO

L<http://nagiosplug.sourceforge.net/developer-guidelines.html>,
L<Nagios::Plugin::Functions>, L<Nagios::Plugin>, L<RRD::Simple>

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


