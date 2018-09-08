#===============================================================================
#
#         FILE:  35xx_snmp_handle.pm
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
use Net::SNMP qw(:asn1);


=item
!!set port speed by tariff set_port_speed(ip_switch, n_port, speed);
set port description	 set_port_description(ip_switch, n_port, n_description);
!!set port state			 set_port_state(ip_switch, n_port, n_portstate); n_portstate = 0||1
set port vlan			 set_port_vlan(ip_switch, n_port, n_vlan);
!!get port speed by port 	 get_port_speed(ip_switch, n_port);
get port description	 get_port_description(ip_switch, n_port);
!!get port state			 get_port_state(ip_switch, n_port);
!!get port vlan			 get_port_vlan(ip_switch, n_port);
del port from vlan		 del_port_vlan(ip_switch, n_port, n_vlan);
=cut


package SNMP_Handle_sw; 
require Exporter;

my @ISA = qw(Exporter);
my @EXPORT = qw(&set_port_speed &set_port_description &set_port_state &set_port_vlan &get_port_speed &get_port_description &get_port_state &get_port_vlan &get_sysdescr);

sub set_port_speed {
#set port speed by tariff set_port_speed(ip_switch, n_port, tx_speed, rx_speed);
my $hostname = shift @_;
my $n_port = shift @_;
my $tx_speed = shift @_;
my $rx_speed = shift @_;
my $result;
my @oidlist;
my $oidlist;
my $community = "c";
my $swL2QOSBandwidthTxRate = "1.3.6.1.4.1.171.11.64.1.2.6.1.1.2";
my $swL2QOSBandwidthRxRate = "1.3.6.1.4.1.171.11.64.1.2.6.1.1.3";
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
										   -community     => $community);
	if(!defined($session)){
		printf("ERROR: %s.\n", $error);
		exit 1;
	}
	@oidlist = ();

            $swL2QOSBandwidthTxRate = $swL2QOSBandwidthTxRate.".".$n_port;
            $oidlist = [($swL2QOSBandwidthTxRate, 2, $tx_speed)];

	$result = $session->set_request(                                                                        
                          -varbindlist      => $oidlist                                              
                      );                                                                            
	@oidlist = ();
            $swL2QOSBandwidthRxRate = $swL2QOSBandwidthRxRate.".".$n_port;
            $oidlist = [($swL2QOSBandwidthRxRate, 2, $rx_speed)];

	$result = $session->set_request(                                                                        
                          -varbindlist      => $oidlist                                              
                      );                                                                            

   if(!defined($result)){                                                                                 
    printf("ERROR: %s.\n", $session->error);                                                       
    $session->close;                                                                               
    exit 1;                                                                                        
   }                                                                                                       

   $session->close;                                                                                        
   return($result->{$swL2QOSBandwidthRxRate});
}

sub set_port_description {
#snmpset -v2c -c c 192.168.0.1  1.3.6.1.4.1.171.11.64.1.2.4.2.1.9.1 s test
#set port description	 set_port_description(ip_switch, n_port, n_description);
my $hostname = shift @_;
my $n_port = shift @_;
my $n_description = shift @_;
my $result;
my @oidlist;
my $oidlist;
my $community = "c";
my $swL2PortCtrlDescription = "1.3.6.1.2.1.31.1.1.1.18";
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
                                           -community     => $community);
	if(!defined($session)){
        printf("ERROR: %s.\n", $error);
        exit 1;
    }
    @oidlist = ();

            $swL2PortCtrlDescription = $swL2PortCtrlDescription.".".$n_port;
            $oidlist = [($swL2PortCtrlDescription, 4, $n_description)];

    $result = $session->set_request(
                          -varbindlist      => $oidlist
                      );

   if(!defined($result)){
    printf("ERROR: %s.\n", $session->error);
    $session->close;
    exit 1;
   }

   $session->close;
   return($result->{$swL2PortCtrlDescription});
}

sub set_port_state {
#set port state			 set_port_state(ip_switch, n_port, n_portstate); n_portstate = 0||1
my $hostname = shift @_;
my $n_port = shift @_;
my $n_portstate = shift @_;

	my $swL2PortCtrlAdminState = "1.3.6.1.4.1.171.11.64.1.2.4.2.1.3";
	my $disable = 2;
	my $enable = 3;
 	my $result;
	my @oidlist;
	my $oidlist;
	my $community = "c";
	my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
											   -community     => $community);
	if (!defined($session)) {
             printf("ERROR: %s.\n", $error);
             exit 1;
    }

	@oidlist = ();

		if($n_portstate){
			$swL2PortCtrlAdminState = $swL2PortCtrlAdminState.".".$n_port;
			$oidlist = [($swL2PortCtrlAdminState, 2, $enable)];
		}else{
			$swL2PortCtrlAdminState = $swL2PortCtrlAdminState.".".$n_port;
			$oidlist = [($swL2PortCtrlAdminState, 2, $disable)];
		}

	$result = $session->set_request(
                                 -varbindlist      => $oidlist
                              );
	if(!defined($result)) {
             printf("ERROR: %s.\n", $session->error);
             $session->close;
             exit 1;
    }
	$session->close;
	return($result->{$swL2PortCtrlAdminState});
}

sub del_port_vlan {
#del port vlan            del_port_vlan(ip_switch, n_port, n_vlan);
my $hostname = shift @_;
my $n_port = shift @_;
my $n_vlan = shift @_;
my $swL2TagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.2";
my $swL2UnTagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.4";
my ($result, $result_tag, $result_untag);
my @oidlist;
my $oidlist;
my $community = "c"; 
my $bit_tag = 0;
my $bitwise_tag = 0;
my $bitwise = 0;
my $bitwise_untag = 0x00000000;
my $bit_mask_tag = 0;
my $bit_untag = 0;
my $bitmapport = 0;
my $bit;
my $bit_mask_untag = 0;
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
										   -translate	=> 0,
									       -community     => $community);                           
if(!defined($session)){
	printf("ERROR: %s.\n", $error);                                                            
			exit 1;                                                                                    
}                                                                                                   
# Getting current untagged port bitmap
@oidlist = ();
	$swL2UnTagVlan = $swL2UnTagVlan.".".$n_vlan;
	$oidlist = [($swL2UnTagVlan)];
$result_untag = $session->get_request(                                                                    
								-varbindlist      => $oidlist                                          
												);                                                                        
if(!defined($result_untag)) {
		printf("ERROR: %s\n", $session->error);                                                   
		$session->close;                                                                           
		exit 1;                                                                                    
}                                                                                                   
	$bitwise_untag = Helper::hex_format($result_untag->{$swL2UnTagVlan});
	print "BITWISE_UNTAG0: $bitwise_untag\n";
	$bitmapport =  Helper::port2bitmap($n_port);
	$bit_untag = eval($bitwise_untag) & ~eval($bitmapport);
	#$bit_untag = $bitwise_untag & ~$bitmapport;
	$bit_mask_untag = sprintf("%08x", $bit_untag);
	print "PORT: $bitmapport\n";
	print "BITWISE_UNTAG: $bitwise_untag\n";
	print "BITMAPPORT: $bitmapport\n";
	print "BIT_UNTAG: $bit_untag\n";
	print "BIT_MASK_UNTAG: $bit_mask_untag\n";

$swL2UnTagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.4";
@oidlist = ();                                                                                                            
   $swL2UnTagVlan = $swL2UnTagVlan.".".$n_vlan;                                                                          
	$oidlist = [($swL2UnTagVlan, 4, pack("H8",$bit_mask_untag))];                                                         
	$result_untag = $session->set_request(                                                                                    
										-varbindlist      => $oidlist                                                             
																	);                                                                        
if(!defined($result_untag)) {                                                                                             
		printf("ERROR: %s.\n", $session->error);                                                                          
					$session->close;                                                                                                  
					exit 1;                                                                                                           
}

# Getting current tagged port bitmap
@oidlist = ();
	$swL2TagVlan = $swL2TagVlan.".".$n_vlan;
	$oidlist = [($swL2TagVlan)];
$result_tag = $session->get_request(                                                                    
								-varbindlist      => $oidlist                                          
												);                                                                        
if(!defined($result_tag)) {
		printf("ERROR: %s.\n", $session->error);                                                   
		$session->close;                                                                           
		exit 1;                                                                                    
}                                                                                                   
	$bitwise_tag = Helper::hex_format($result_tag->{$swL2TagVlan});
	$bitmapport =  Helper::port2bitmap($n_port);
	$bit_tag = eval($bitwise_tag) & ~eval($bitmapport);
	#$bit_tag = $bitwise_tag & ~$bitmapport;
	$bit_mask_tag = sprintf("%08x", $bit_tag);
	print "BITWISE_TAG: $bitwise_tag\n";
	print "BITMAPPORT: $bitmapport\n";
	print "BIT_TAG: $bit_tag\n";
	print "BIT_MASK_TAG: $bit_mask_tag\n";

	$swL2TagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.2";
	@oidlist = ();
	$swL2TagVlan = $swL2TagVlan.".".$n_vlan;
	$oidlist = [($swL2TagVlan, 4,  pack("H8",$bit_mask_tag))];
	#$oidlist = [($swL2TagVlan, 4,  $bit_mask_tag)];
	$result_tag = $session->set_request(                                                                    
								-varbindlist      => $oidlist                                          
												);                                                                        
if(!defined($result_tag)) {
		printf("ERROR: %s.\n", $session->error);                                                   
		$session->close;                                                                           
}
    
	$session->close;
return(Helper::hex_format($result_tag->{$swL2TagVlan}));

}

sub set_port_vlan {
#set port vlan            set_port_vlan(ip_switch, n_port, n_vlan);
my $hostname = shift @_;
my $n_port = shift @_;
my $n_vlan = shift @_;
my $swL2TagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.2";
my $swL2UnTagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.4";
my ($result, $result_tag, $result_untag);
my @oidlist;
my $oidlist;
my $community = "c"; 
my $bit_tag = 0;
my $bitwise_tag = 0;
my $bitwise = 0;
my $bitwise_untag = 0x00000000;
my $bit_mask_tag = 0;
my $bit_untag = 0;
my $bitmapport = 0;
my $bit;
my $bit_mask_untag = 0;
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,                             
										   -translate	=> 0,
									       -community     => $community);                           
if(!defined($session)){
	printf("ERROR: %s.\n", $error);                                                            
			exit 1;                                                                                    
}                                                                                                   

# Getting info about current vlan id for port
my $vlan_port = get_port_vlan($hostname, $n_port);

if($n_vlan == $vlan_port){
	print "VLAN Id: ".$n_vlan." was added early\n";
	return 1;
}

my $res = SNMP_Handle_sw::del_port_vlan($hostname,$n_port, SNMP_Handle_sw::get_port_vlan($hostname,$n_port));

# Getting current tagged port bitmap
@oidlist = ();
	$swL2TagVlan = $swL2TagVlan.".".$n_vlan;
	$oidlist = [($swL2TagVlan)];
$result_tag = $session->get_request(                                                                    
								-varbindlist      => $oidlist                                          
												);                                                                        
if(!defined($result_tag)) {
		printf("ERROR: %s.\n", $session->error);                                                   
		$session->close;                                                                           
		exit 1;                                                                                    
}                                                                                                   
	$bitwise_tag = Helper::hex_format($result_tag->{$swL2TagVlan});
	print "BITWISE_TAG0: $bitwise_untag\n";
	$bitmapport =  Helper::port2bitmap($n_port);
	$bit_tag = eval($bitwise_tag) | eval($bitmapport);
	$bit_mask_tag = sprintf("%08x", $bit_tag);
	print "BITWISE_TAG: $bitwise_tag\n";
	print "BITMAPPORT: $bitmapport\n";
	print "BIT_TAG: $bit_tag\n";
	print "BIT_MASK_TAG: $bit_mask_tag\n";

# Getting current untagged port bitmap
@oidlist = ();
	$swL2UnTagVlan = $swL2UnTagVlan.".".$n_vlan;
	$oidlist = [($swL2UnTagVlan)];
$result_untag = $session->get_request(                                                                    
								-varbindlist      => $oidlist                                          
												);                                                                        
if(!defined($result_untag)) {
		printf("ERROR: %s\n", $session->error);                                                   
		$session->close;                                                                           
		exit 1;                                                                                    
}                                                                                                   
	$bitwise_untag = Helper::hex_format($result_untag->{$swL2UnTagVlan});
	print "BITWISE_UNTAG0: $bitwise_untag\n";
	$bitmapport =  Helper::port2bitmap($n_port);
	$bit_untag = eval($bitwise_untag) | eval($bitmapport);
	$bit_mask_untag = sprintf("%08x", $bit_untag);
	print "PORT: $bitmapport\n";
	print "BITWISE_UNTAG: $bitwise_untag\n";
	print "BITMAPPORT: $bitmapport\n";
	print "BIT_UNTAG: $bit_untag\n";
	print "BIT_MASK_UNTAG: $bit_mask_untag\n";

$swL2TagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.2"; 
$swL2UnTagVlan = "1.3.6.1.2.1.17.7.1.4.3.1.4";

@oidlist = ();
	$swL2TagVlan = $swL2TagVlan.".".$n_vlan;
	$oidlist = [($swL2TagVlan, 4,  pack("H8",$bit_mask_tag))];
	#$oidlist = [($swL2TagVlan, 4,  $bit_mask_tag)];
$result_tag = $session->set_request(                                                                    
								-varbindlist      => $oidlist                                          
												);                                                                        
if(!defined($result_tag)) {
		printf("ERROR: %s.\n", $session->error);                                                   
		$session->close;                                                                           
		exit 1;                                                                                    
}                                                                                                   

@oidlist = ();
	$swL2UnTagVlan = $swL2UnTagVlan.".".$n_vlan;
	$oidlist = [($swL2UnTagVlan, 4, pack("H8",$bit_mask_untag))];
$result_untag = $session->set_request(                                                                    
								-varbindlist      => $oidlist                                          
												);                                                                        
if(!defined($result_untag)) {
		printf("ERROR: %s.\n", $session->error);                                                   
		$session->close;                                                                           
		exit 1;                                                                                    
}                                                                                                   

	$session->close;
return(Helper::hex_format($result_tag->{$swL2TagVlan}));
}


sub get_port_speed {
#get port speed by port 	 get_port_speed(ip_switch, n_port);
my $hostname = shift @_;
my $n_port = shift @_;
my $tx_speed = shift @_;
my $rx_speed = shift @_;
my $result;
my @oidlist;
my $oidlist;
my $community = "c";
my $swL2QOSBandwidthTxRate = "1.3.6.1.4.1.171.11.64.1.2.6.1.1.2";
my $swL2QOSBandwidthRxRate = "1.3.6.1.4.1.171.11.64.1.2.6.1.1.3";
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
                                           -community     => $community);
    if(!defined($session)){
        printf("ERROR: %s.\n", $error);
        exit 1;
    }
    @oidlist = ();

            $swL2QOSBandwidthTxRate = $swL2QOSBandwidthTxRate.".".$n_port;
            $oidlist = [($swL2QOSBandwidthTxRate)];

    $result = $session->get_request(
                          -varbindlist      => $oidlist
                      );
    @oidlist = ();
            $swL2QOSBandwidthRxRate = $swL2QOSBandwidthRxRate.".".$n_port;
            $oidlist = [($swL2QOSBandwidthRxRate)];

    $result = $session->get_request(
                          -varbindlist      => $oidlist
                      );

   if(!defined($result)){
    printf("ERROR: %s.\n", $session->error);
    $session->close;
    exit 1;
   }

   $session->close;
   return($result->{$swL2QOSBandwidthRxRate});
}

sub get_port_description {
#snmpget -v2c -c c 192.168.0.1 1.3.6.1.2.1.31.1.1.1.18
##set port description    set_port_description(ip_switch, n_port);
my $hostname = shift @_;
my $n_port = shift @_;
my $n_description = shift @_;
my $result;
my @oidlist;
my $oidlist;
my $community = "public";
my $swL2PortCtrlDescription = "1.3.6.1.2.1.31.1.1.1.18";
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,
                                           -community     => $community);
                                               if(!defined($session)){
        printf("ERROR: %s.\n", $error);
        exit 1;
    }
    @oidlist = ();

            $swL2PortCtrlDescription = $swL2PortCtrlDescription.".".$n_port;
            $oidlist = [($swL2PortCtrlDescription)];

    $result = $session->get_request(
                          -varbindlist      => $oidlist
                      );

   if(!defined($result)){
    printf("ERROR: %s.\n", $session->error);
    $session->close;
    exit 1;
   }

   $session->close;
   return($result->{$swL2PortCtrlDescription});
}

sub get_port_state {
#get port state          get_port_state(ip_switch, n_port);                           
my $hostname = shift @_;
my $n_port = shift @_;
my $swL2PortCtrlAdminState = "1.3.6.1.4.1.171.11.64.1.2.4.2.1.3";                                                                      
my $result;
my @oidlist;
my $oidlist;
my $community = "public";
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,   
                           -community     => $community);                                                              
	if (!defined($session)) {
             printf("ERROR: %s.\n", $error);
             exit 1;
    }

  @oidlist = ();

            $swL2PortCtrlAdminState = $swL2PortCtrlAdminState.".".$n_port;
            $oidlist = [($swL2PortCtrlAdminState)];                                                                            

    $result = $session->get_request(                            
                                 -varbindlist      => $oidlist
                              );   
    if(!defined($result)) {
             printf("ERROR: %s.\n", $session->error);
             $session->close;
             exit 1;
    }
    $session->close;
    return($result->{$swL2PortCtrlAdminState});                                                                                            

}

sub get_port_vlan {
#get port vlan            get_port_vlan(ip_switch, n_port);
my $hostname = shift @_;                                                                                
my $n_port = shift @_;
my $swL2Untag = ".1.3.6.1.2.1.17.7.1.4.5.1.1";                                                                      
my $result;
my @oidlist;
my $oidlist;
my $community = "public";
my ($session, $error) = Net::SNMP->session(-hostname      => $hostname,   
                           -community     => $community);                                                              
	if (!defined($session)) {
             printf("ERROR: %s.\n", $error);
             exit 1;
    }

  @oidlist = ();

            $swL2Untag = $swL2Untag.".".$n_port;
            $oidlist = [($swL2Untag)];                                                                            

    $result = $session->get_request(                            
                                 -varbindlist      => $oidlist
                              );   
    if(!defined($result)) {
             printf("ERROR: %s.\n", $session->error);
             $session->close;
             exit 1;
    }
    $session->close;
    return($result->{$swL2Untag});                                                                                            
}

1;
