#!perl
use Mac::Comm::OT_PPP;
$ppp = new Mac::Comm::OT_PPP;
$user = 'chrisn';
$pass = 'password';
$adrs = '5551212';

$ppp->PPPdisconnect;
$ppp->PPPconnect($user,$pass,$adrs);

$hash = $ppp->PPPstatus;
foreach $key (keys %{$hash}) {
    print "$key: $$hash{$key}\n";
}

$ppp->PPPsavelog('PowerPudge:Desktop Folder:temp');

print "Done.\n\n";
