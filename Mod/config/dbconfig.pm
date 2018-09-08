package config::dbconfig;

use Exporter;

@ISA=qw(Exporter);
@EXPORT=qw(%dbcfg);

$dbcfg{'host'}='10.222.1.1';
$dbcfg{'sid'}='H';
$dbcfg{'port'}='1521';
$dbcfg{'user'}='u';
$dbcfg{'password'}='p';

#$ENV{ORACLE_HOME}='/usr/local/oracle8-client';
#$ENV{ORACLE_HOME}='/usr/lib/oracle/11.2/client';
$ENV{ORACLE_HOME}='/usr/local/oracle8-client';
$ENV{NLS_LANG}='AMERICAN_AMERICA.CL8KOI8R';
$ENV{NLS_DATE_FORMAT}='DD-MM-YYYY';

1;
