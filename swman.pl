#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  swman.pl
#
#        USAGE:  ./swman.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Mitya, 
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  11.12.2012 13:08:36
#     REVISION:  ---
#===============================================================================

use strict;
#use warnings;
use DBI;

use lib "/home/swman/Mod";
use Helper;
use Debtors;
use Tariffs;
use Policy;
use Rules;
use config::dbconfig;


my ($dbh,$sth,$sql);
my ($obj, $ip, $port, $sql_servkind, $sth_servkind, $servkind, @serv, %sw, $ip_sw, $port_sw, $sw, $i, $fl, $status_bunch, $identifer, $process);
my ($fullname, $addr, $pay, $vlan, $vlan_id);
my (%kind, $debtors);
my ($refdeb);
my ($reftariff, $deb);

$refdeb = Debtors::get_debtors();
$reftariff = Tariffs::get_tariffs();
$sw = Policy::get_policy($refdeb);
Rules::rules_to_switch($sw, $reftariff);
