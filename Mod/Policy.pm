#!/usr/bin/perl

package Policy; 
require Exporter;

my @ISA = qw(Exporter);
my @EXPORT = qw(&get_policy);

use strict;
use DBI;

use lib "/home/swman/Mod";
use Helper;
use Debtors;
use Tariffs;

use config::dbconfig;


sub get_policy {

my ($dbh,$sth,$sql);
my ($ip, $port, $obj, $ip, $port, $sql_servkind, $sth_servkind, $servkind, @serv, %sw, $ip_sw, $port_sw, $sw, $i, $fl, $status_bunch, $identifer, $process);
my ($fullname, $addr, $pay, $vlan, $vlan_id);
my (%kind, $debtors, );
my ($refdeb);

$refdeb = $_[0];

$dbh = DBI->connect("dbi:Oracle:host=$dbcfg{'host'};sid=$dbcfg{'sid'};port=$dbcfg{'port'}",$dbcfg{'user'},$dbcfg{'password'})
            or die "Can't connect with Oracle:$dbcfg{'sid'}_$dbcfg{'host'} under user:$dbcfg{'user'}\n";

$sql="select switch.ip,port,id_obj,status, v.num
	  from hyper.users, hyper.switch, hyper.nets n, hyper.vlan v, hyper.sw_vlan_net svn
	  where users.id_sw=switch.id_sw
	  and v.id_vl = svn.id_vl
	  and n.id_nt = svn.id_nt
	  and hyper.switch.id_sw = svn.id_sw"; # and status=1";
$sth=$dbh->prepare($sql);
$sth->execute;

while(($ip, $port, $obj, $status_bunch, $vlan_id)=$sth->fetchrow_array){
	if(defined($obj)){
		$sql_servkind = "select distinct a.servkind_code, c.identifer, c.process
		from fastcom25.ct_t_contr_serv a,fastcom25.ct_t_object c, fastcom25.cl_t_client cl, fastcom25.ct_t_contract ct
		where a.controbj_id=".$obj."
		and sysdate between a.hist_from and a.hist_to 
		and a.controbj_id = c.id
		and c.contract_id = ct.id
		and cl.id = ct.client_id
		and a.id not in (select distinct b.contr_serv_id from
		fastcom25.ct_t_serv_break b  where 
		sysdate between b.hist_from and b.hist_to)";

		$sth_servkind=$dbh->prepare($sql_servkind);
		$sth_servkind->execute;
	    $servkind='';
		undef @serv;
	    undef %kind;
		while(($servkind, $identifer, $process)=$sth_servkind->fetchrow_array){
				 $sw->{$ip}->{$port}->{'identifer'} = $identifer;
				 $kind{'serv'} = $servkind;
				 $kind{'process'} = $process;
				 push(@serv, {%kind});
				 undef %kind
		}
		$sw->{$ip}->{$port}->{"serv"} = [ @serv ];
		$sw->{$ip}->{$port}->{"obj"} = $obj;
		$sw->{$ip}->{$port}->{"status_bunch"} = $status_bunch;
		if(defined($refdeb->{$sw->{$ip}->{$port}->{'identifer'}})){
				$sw->{$ip}->{$port}->{"debtor"} = $refdeb->{$sw->{$ip}->{$port}->{'identifer'}};
			}else{
				$sw->{$ip}->{$port}->{"debtor"} = 0;
		}
		$sw->{$ip}->{$port}->{"vlan"} = $vlan_id;
		$sth_servkind->finish;
	}
}
$sth->finish;
$dbh->disconnect;

return($sw);
}
  
1
