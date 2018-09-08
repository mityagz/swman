#===============================================================================
#
#         FILE:  Helper.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Mitya, 
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  09.11.2012 16:40:44
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Net::SNMP;

=item
get_sysdescr
=cut


package Helper; 
require Exporter;

my @ISA = qw(Exporter);
my @EXPORT = qw(&get_sysdescr);

sub get_sysdescr {
	my $hostname = shift @_;
	my $SysDescr = ".1.3.6.1.2.1.1.1.0";
	my $community = "public";
	my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
											   -community     => $community);
	if (!defined($session)) {
             printf("ERROR: %s.\n", $error);
             exit 1;
    }

	my $result = $session->get_request(
                                 -varbindlist      => [$SysDescr]
                              );
	if (!defined($result)) {
             printf("ERROR: %s.\n", $session->error);
             $session->close;
             exit 1;
    }
	$session->close;
	return($result->{$SysDescr});
}

sub save_conf_3526 {
	my $hostname = shift @_;
    my $agentSaveCfg = "1.3.6.1.4.1.171.12.1.2.6.0";
    my $community = "c";
	my @oidlist;
	my $oidlist;
	my $result;
    my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
                                               -community     => $community,
											   -timeout		  => 60);
	if (!defined($session)) {
             printf("ERROR: %s.\n", $error);
             exit 1;
    }

	@oidlist = ();

            $oidlist = [($agentSaveCfg, 2, 3)];

    $result = $session->set_request(
                          -varbindlist      => $oidlist
                      );

    if (!defined($result)) {
             printf("ERROR: %s.\n", $session->error);
             $session->close;
             exit 1;
    }
    $session->close;
	return($result->{$agentSaveCfg});
}

sub port2bitmap {
my $n_port = shift @_;
my $i;
my ($bin1, $bin2, $bin3, $bin4, $bin) = 0;
my ($hex1, $hex2, $hex3, $hex4, $hex) = 0;
$bin = "";

for($i = 1; $i <= 31; $i++){
 if($i == $n_port){
    $bin = $bin.1;
 }else{
    $bin = $bin.0;
 }
}
    $bin1 = substr($bin,0,8);
    $bin2 = substr($bin,8,8);
    $bin3 = substr($bin,16,8);
    $bin4 = substr($bin,24,8);
    $hex1 = sprintf("%02x",oct("0b$bin1"));
    $hex2 = sprintf("%02x",oct("0b$bin2"));
    $hex3 = sprintf("%02x",oct("0b$bin3"));
    $hex4 = sprintf("%02x",oct("0b$bin4"));
    $hex =  $hex1.$hex2.$hex3.$hex4;

	return "0x".$hex;
	#return $hex;
}

sub oct_str {
my $e = shift @_;
my ($i, $k);
	for($i = 0; $i < length($e); $i = $i+2){
        	$k .= '\x'.substr($e, $i, 2);
	}
	#$k = '\"'.$k.'\"';
return($k);
}

sub hex_format{
  return  sprintf("0x"."%08s", unpack "H8", $_[0]);
}

1;
