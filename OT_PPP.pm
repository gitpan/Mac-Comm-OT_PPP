#!perl -w
#-----------------------------------------------------------------#
#  OT_PPP.pm
#  pudge
#  Interface to OT/PPP (Open Transport PPP)
#
#  Created:       Chris Nandor (pudge@pobox.com)         04-May-97
#  Last Modified: Chris Nandor (pudge@pobox.com)         04-May-97
#-----------------------------------------------------------------#
package Mac::Comm::OT_PPP;

=head1 NAME

Mac::Comm::OT_PPP - Interface to Open Transport PPP

=head1 SYNOPSIS

	use Mac::Comm::OT_PPP;
	$ppp = new Mac::Comm::OT_PPP;

=head1 DESCRIPTION

This module allows you to do basic operations with OT/PPP, the PPP connection software from Apple Computer designed for use with their Open Transport networking architecture.  For more information on Open Transport or OT/PPP, see the Open Transport web site.

=head1 USAGE

=over

=cut

#-----------------------------------------------------------------
require 5.00201;
use Exporter;
use Carp;
#-----------------------------------------------------------------
@ISA = qw(Exporter);
@EXPORT = ();
#-----------------------------------------------------------------
$Mac::Comm::OT_PPP::revision = '$Id: OT_PPP.pm,v 1.0 1997/05/04 19:46 EST cnandor Exp $';
$Mac::Comm::OT_PPP::VERSION  = '1.0';
#-----------------------------------------------------------------
use Mac::AppleEvents;
#=================================================================
# Stuff
#=================================================================
sub new {
	my $self = shift;
	return bless{}, $self;
}
#-----------------------------------------------------------------
sub revision {
	return $revision;
}
#-----------------------------------------------------------------
sub version {
	return $VERSION;
}
#-----------------------------------------------------------------

=item PPPconnect

	$ppp->PPPconnect(USER,PASS,ADRS);

Connect to phone number ADRS as user USER with password PASS.

=cut

sub PPPconnect {
	my($self,$user,$pass,$adrs,$diag,$be,$rp,$at);
	$self = shift;
	$user = shift || croak "username left blank\n";
	$pass = shift || croak "password left blank\n";
	$adrs = shift || croak "phone # left blank\n";
	$be = AEBuildAppleEvent('netw','RAco',typeApplSignature,'MACS',0,0,'') || croak $^E;
	AEPutParam($be,'RAun','TEXT',$user);
	AEPutParam($be,'RApw','TEXT',$pass);
	AEPutParam($be,'RAad','TEXT',$adrs);
	$rp = AESend($be, kAEWaitReply) || croak $^E;
	$at = AEGetParamDesc($rp,'errn');
	return AEPrint($at) if ($at);
}
#-----------------------------------------------------------------

=item PPPdisconnect

	$ppp->PPPdisconnect;

Disconnect.

=cut

sub PPPdisconnect {
	my($be,$rp,$at);
	$be = AEBuildAppleEvent('netw','RAdc',typeApplSignature,'MACS',0,0,'') || croak $^E;
	$rp = AESend($be, kAEWaitReply) || croak $^E;
	$at = AEGetParamDesc($rp,'errn');
	return AEPrint($at) if ($at);
}
#-----------------------------------------------------------------

=item PPPstatus

	$hash = $ppp->PPPstatus;
	foreach $key (keys %{$hash}) {
		print "$key: $$hash{$key}\n";
	}

Return status:

=over 8

=item RAsb

State of connection

=item RAsc

Seconds connected

=item RAsr

Seconds remaining

=item RAun

User name

=item RAsn

Server name

=item RAms

Most recent message for connection

=item RAbm

Baud rate of connection

=item RAbi

Bytes in/received

=item RAbo

Bytes out/sent

=item RAsp

Connection type (?)

=back

=cut

sub PPPstatus {
	my($be,$rp,$aq,$at,@ar,$ar,%ar);
	$be = AEBuildAppleEvent('netw','RAst',typeApplSignature,'MACS',0,0,'') || croak $^E;
	$rp = AESend($be, kAEWaitReply) || croak $^E;
	$at = AEGetParamDesc($rp,'errn');
	return AEPrint($at) if ($at);

	$aq = AEGetParamDesc($rp,'----');
	@ar = qw(RAsb RAsc RAun RAsn RAms RAsp RAbm RAbi RAbo RAsr);
	foreach $ar(@ar) {
		if ($at = AEGetParamDesc($aq,$ar)) {
			($ar{$ar} = AEPrint($at)) =~ s/^Ò(.*)Ó$/$1/s;
			delete $ar{$ar} if ($ar{$ar} eq q{'TEXT'()});
		}
	}

	return AEPrint($ar{'errn'}) if ($ar{'errn'});
	return \%ar;
}
#-----------------------------------------------------------------

=item PPPsavelog

	$ppp->PPPsavelog(FILE);

Save log to file of filepath FILE.  Operation can take a minute or two if the log is big, and might freeze up your computer while working.  Be patient.

=cut

sub PPPsavelog {
	my($self,$file,$be,$rp,$at);
	$self = shift;
	$file = shift || croak "filename left blank\n";
	$be = AEBuildAppleEvent('netw','RAsl',typeApplSignature,'MACS',0,0,'') || croak $^E;
	AEPutParam($be,'RAlf','TEXT',$file) if ($file);
	$rp = AESend($be, kAEWaitReply) || croak $^E;
	$at = AEGetParamDesc($rp,'errn');
	return AEPrint($at) if ($at);
}
#-----------------------------------------------------------------#

__END__

=back

=head1 VERSION NOTES

=over

=item v.1.0 May 4, 1997

Took some code and threw it in a module.

=back

=head1 SEE ALSO

=over

=item Open Transport Home Page

http://tuvix.apple.com/dev/opentransport

=back

=head1 AUTHOR / COPYRIGHT

Chris Nandor, 04-May-1997

	mailto:pudge@pobox.com
	http://pudge.net/

Copyright (c) 1997 Chris Nandor.  All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.  Please see the Perl Artistic License.

=cut
