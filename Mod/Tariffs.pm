#!/usr/bin/perl

use strict;
use DBI;
use POSIX;

package Tariffs; 
require Exporter;

my @ISA = qw(Exporter);
my @EXPORT = qw(&get_tariffs);


use config::dbconfig;

my ($dbh,$sth,$sql);
my ($servcode, %tariffs, $speed_day, $speed_night);



sub get_tariffs {
$0 = "[ swman ] Get tarifs";
$dbh = DBI->connect("dbi:Oracle:host=$dbcfg{'host'};sid=$dbcfg{'sid'};port=$dbcfg{'port'}",$dbcfg{'user'},$dbcfg{'password'})
            or die "Can't connect with Oracle:$dbcfg{'sid'}_$dbcfg{'host'} under user:$dbcfg{'user'}\n";

$sql="select tr.servcode, tr.speed, tr.speed_night, tr.date_from, tr.date_to
	  from hyper.tariff_un tr
	  where date_to is NULL";

$sth=$dbh->prepare($sql);
$sth->execute;



while(($servcode, $speed_day, $speed_night)=$sth->fetchrow_array){
	if(defined($servcode)){
		$tariffs{$servcode}->{'speed_day'} = (split(/ /, $speed_day))[0];
		$tariffs{$servcode}->{'speed_night'} = (split(/ /, $speed_night))[0];
	}
}

$sth->finish;
$dbh->disconnect;
$0 = "[ swman ]";
	return \%tariffs;
}

sub normalize_speed_parm {
my ($reftariff, $servcode, $type_dev, $speed_type, $speed);
$reftariff = $_[0];
$servcode = $_[1];
$type_dev = $_[2];
$speed_type = $_[3];

	if($type_dev =~ /3526/){
			    $speed = $reftariff->{$servcode}->{$speed_type};
				if($speed < 1000000){
					$speed = 1;
					return $speed;
				}
			    $speed = $reftariff->{$servcode}->{$speed_type}/1000000;
				$speed = POSIX::floor($speed);
				$speed = 100 if $speed > 100;
				##print $reftariff->{$servcode}->{$speed_type}."\n";
				##print "$speed\n";
	}
	return $speed;
}
	
1;
