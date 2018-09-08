use strict;
use Net::SNMP;

use lib "/home/swman/Mod";

package Rules;
require Exporter;

use SNMP_Handle_sw;
use POSIX ':sys_wait_h';

my @ISA = qw(Exporter);
my @EXPORT = qw(&rules_to_switch);

sub timeofday {
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;

    if($hour >= 1 and $hour <= 6){
        return "speed_night";
    }else{
        return "speed_day";
    }
}

sub rules_to_switch {

my ($dbh,$sth,$sql);
my ($obj, $ip, $port, $sql_servkind, $sth_servkind, $servkind, @serv, %sw, $ip_sw, $port_sw, $sw, $i, $fl, $status_bunch, $identifer, $process);
my ($fullname, $addr, $pay, $vlan, $vlan_id);
my (%kind, $debtors);
my ($refdeb);
my ($reftariff, $deb);

$sw = $_[0];
$reftariff = $_[1];

# Checking hash structure.
	foreach $ip_sw (keys %{$sw}){
		if(1){
		if(fork() == 0){
		foreach $port_sw (keys %{$sw->{$ip_sw}}){
						$fl=0;
			for($i = 0;  $i < scalar @{$sw->{$ip_sw}->{$port_sw}->{"serv"}}; $i++){
					  if(defined($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i])){
						if($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'} =~ /TR_UN/){
					     ## This is usually client
						 if(($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'} eq "SERVICE") && ($sw->{$ip_sw}->{$port_sw}->{"debtor"} == 0)){
							print "Key $ip_sw:$port_sw: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}.": ObjectId:".$sw->{$ip_sw}->{$port_sw}->{"obj"}.":Status_bunch :".$sw->{$ip_sw}->{$port_sw}->{"status_bunch"}." Ident: ".$sw->{$ip_sw}->{$port_sw}->{"identifer"}." Process: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'}." Debtor: ".$sw->{$ip_sw}->{$port_sw}->{"debtor"}." Vlan_Id: ".$sw->{$ip_sw}->{$port_sw}->{"vlan"}." Speed_Day: ".$reftariff->{$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}}->{'speed_day'}." Speed_Night: ".$reftariff->{$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}}->{'speed_night'}."\n";
							# Check port decription
							if(SNMP_Handle_sw::get_port_description($ip_sw, $port_sw) ne $sw->{$ip_sw}->{$port_sw}->{"identifer"}){
									SNMP_Handle_sw::set_port_description($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"identifer"})
							}
							# Check port speed
							if(SNMP_Handle_sw::get_port_speed($ip_sw, $port_sw) != Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, timeofday())){
									SNMP_Handle_sw::set_port_speed($ip_sw, $port_sw,  
									Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, timeofday()),  
									Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, timeofday()));
							}
							# Check vlan 
							if(SNMP_Handle_sw::get_port_vlan($ip_sw, $port_sw) != $sw->{$ip_sw}->{$port_sw}->{"vlan"}){
									SNMP_Handle_sw::set_port_vlan($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"vlan"});
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 0);
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 1);
							}
							# Check port state shut/no shut
							if(SNMP_Handle_sw::get_port_state($ip_sw, $port_sw) == 2){
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 1);
							}
					     ## This is a debtor, or client with suspened service  put it into debtor vlan
 						 }elsif((($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'} eq "SERVICE") && ($sw->{$ip_sw}->{$port_sw}->{"debtor"} == 1)) || (($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'}) eq "BLOCK") || ($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'} eq "STOP")){
							print "Key $ip_sw:$port_sw: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}.": ObjectId:".$sw->{$ip_sw}->{$port_sw}->{"obj"}.":Status_bunch :".$sw->{$ip_sw}->{$port_sw}->{"status_bunch"}." Ident: ".$sw->{$ip_sw}->{$port_sw}->{"identifer"}." Process: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'}." Debtor: ".$sw->{$ip_sw}->{$port_sw}->{"debtor"}." Vlan_Id: ".$sw->{$ip_sw}->{$port_sw}->{"vlan"}." Speed_Day: ".$reftariff->{$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}}->{'speed_day'}." Speed_Night: ".$reftariff->{$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}}->{'speed_night'}."\n";
							# Check port decription
							if(SNMP_Handle_sw::get_port_description($ip_sw, $port_sw) ne $sw->{$ip_sw}->{$port_sw}->{"identifer"}){
									SNMP_Handle_sw::set_port_description($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"identifer"})
							}
							# Check port speed
							if(SNMP_Handle_sw::get_port_speed($ip_sw, $port_sw) != Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, 'speed_day')){
									SNMP_Handle_sw::set_port_speed($ip_sw, $port_sw,  
									Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, timeofday()),  
									Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, timeofday()));
							}
							# Check vlan 
							if(SNMP_Handle_sw::get_port_vlan($ip_sw, $port_sw) != $sw->{$ip_sw}->{$port_sw}->{"vlan"} + 1){
									SNMP_Handle_sw::set_port_vlan($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"vlan"} + 1);
							# Set port to shutdown and no shutdown for correct bring ipv4 address after vlan id change
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 0);
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 1);
							}
							# Check port state shut/no shut
							if(SNMP_Handle_sw::get_port_state($ip_sw, $port_sw) == 2){
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 1);
							}
						 ## This is bloking clients, set port to shutdown
						 }elsif(($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'} eq "CANCEL") || ($sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'} eq "ATTACH") ){
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 0);	
						 }
							$fl=1;
						}
					}else{
							print "Key $ip_sw:$port_sw: switch off 0: ObjectId:".$sw->{$ip_sw}->{$port_sw}->{"obj"}.":Status_bunch :".$sw->{$ip_sw}->{$port_sw}->{"status_bunch"}." Ident: ".$sw->{$ip_sw}->{$port_sw}->{"identifer"}." Process: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'}." Debtor: ".$sw->{$ip_sw}->{$port_sw}->{"debtor"}." Vlan_Id: ".$sw->{$ip_sw}->{$port_sw}->{"vlan"}."\n";
							# Check port decription
							##if(SNMP_Handle_sw::get_port_description($ip_sw, $port_sw) ne $sw->{$ip_sw}->{$port_sw}->{"identifer"}){
							##		SNMP_Handle_sw::set_port_description($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"identifer"})
							##}
							# Check port speed
							##if(SNMP_Handle_sw::get_port_speed($ip_sw, $port_sw) != Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, 'speed_night')){
							##		SNMP_Handle_sw::set_port_speed($ip_sw, $port_sw,  
							##		Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, 'speed_night'),  
							##		Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, 'speed_night'));
							##}
							# Check vlan 
							if(SNMP_Handle_sw::get_port_vlan($ip_sw, $port_sw) != $sw->{$ip_sw}->{$port_sw}->{"vlan"} + 1){
									SNMP_Handle_sw::set_port_vlan($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"vlan"} + 1);
							# Set port to shutdown and no shutdown for correct bring ipv4 address after vlan id change
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 0);
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 1);
							}
							$fl=1;
					}
			}
			if($fl==0){
							print "Key $ip_sw:$port_sw: switch off 1 : ObjectId:".$sw->{$ip_sw}->{$port_sw}->{"obj"}.":Status_bunch :".$sw->{$ip_sw}->{$port_sw}->{"status_bunch"}." Ident: ".$sw->{$ip_sw}->{$port_sw}->{"identifer"}." Process: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'}." Debtor: ".$sw->{$ip_sw}->{$port_sw}->{"debtor"}." Vlan_Id: ".$sw->{$ip_sw}->{$port_sw}->{"vlan"}."\n";
							# Check port decription
							##if(SNMP_Handle_sw::get_port_description($ip_sw, $port_sw) ne $sw->{$ip_sw}->{$port_sw}->{"identifer"}){
							##		SNMP_Handle_sw::set_port_description($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"identifer"})
							##}
							# Check port speed
							##if(SNMP_Handle_sw::get_port_speed($ip_sw, $port_sw) != Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, 'speed_night')){
							##		SNMP_Handle_sw::set_port_speed($ip_sw, $port_sw,  
							##		Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, 'speed_night'),  
							##		Tariffs::normalize_speed_parm($reftariff, $sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}, 3526, 'speed_night'));
							##}
							# Check vlan 
							if(SNMP_Handle_sw::get_port_vlan($ip_sw, $port_sw) != $sw->{$ip_sw}->{$port_sw}->{"vlan"} + 1){
									SNMP_Handle_sw::set_port_vlan($ip_sw, $port_sw, $sw->{$ip_sw}->{$port_sw}->{"vlan"} + 1);
							# Set port to shutdown and no shutdown for correct bring ipv4 address after vlan id change
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 0);
									SNMP_Handle_sw::set_port_state($ip_sw, $port_sw, 1);
							}
			}
			print "-------------------------------------------------------\n";
		}
	$0 = "[ swman ] ".$ip_sw." save conf";
	sleep 2;
	exit;
	}
	}
	}
	$0 = "[ swman ] Waiting child...";
while(wait() != -1) {}
}
=item
#"Key $ip_sw:$port_sw: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}.
#": ObjectId:".$sw->{$ip_sw}->{$port_sw}->{"obj"}.
#":Status_bunch :".$sw->{$ip_sw}->{$port_sw}->{"status_bunch"}.
#" Ident: ".$sw->{$ip_sw}->{$port_sw}->{"identifer"}.
#" Process: ".$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'process'}.
#" Debtor: ".$sw->{$ip_sw}->{$port_sw}->{"debtor"}.
#" Vlan_Id: ".$sw->{$ip_sw}->{$port_sw}->{"vlan"}.
#" Speed_Day: ".$reftariff->{$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}}->{'speed_day'}.
#" Speed_Night: ".$reftariff->{$sw->{$ip_sw}->{$port_sw}->{"serv"}->[$i]->{'serv'}}->{'speed_night'}."\n";
##$fl=1;
=cut

1;
