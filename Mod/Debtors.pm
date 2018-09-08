#!/usr/bin/perl

use strict;
use DBI;
use Net::SNMP;

package Debtors; 
require Exporter;

my @ISA = qw(Exporter);
my @EXPORT = qw(&get_debtors);


use config::dbconfig;

my ($dbh,$sth,$sql);
my ($identifer, $charge, %debtors);



sub get_debtors {

$0 = "[ swman ] Get debtors";

$dbh = DBI->connect("dbi:Oracle:host=$dbcfg{'host'};sid=$dbcfg{'sid'};port=$dbcfg{'port'}",$dbcfg{'user'},$dbcfg{'password'})
            or die "Can't connect with Oracle:$dbcfg{'sid'}_$dbcfg{'host'} under user:$dbcfg{'user'}\n";

$sql="select distinct obj.identifer, fastcom25.bl_f_get_sldcur_with_curchrg(ct.id)
	  from fastcom25.ct_t_contract ct
	  join fastcom25.ct_t_object obj ON obj.contract_id = ct.id
	  join fastcom25.cl_t_client cl ON ct.client_id = cl.id
	  where  obj.objecttype_code IN ('PPPOE') 
	  and (obj.identifer like 'gf%' or obj.identifer like 'un%')
	  and fastcom25.bl_f_get_sldcur_with_curchrg(ct.id) <= 0";

$sth=$dbh->prepare($sql);
$sth->execute;



while(($identifer, $charge)=$sth->fetchrow_array){
	if(defined($identifer)){
		$debtors{$identifer}=1;
	}
}

$sth->finish;
$dbh->disconnect;
$0 = "[ swman ]";
	return \%debtors;
}
	
1;
