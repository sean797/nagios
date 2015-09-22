#!/usr/bin/perl 
# Available from https://exchange.nagios.org/directory/Plugins/Email-and-Groupware/Postfix/Check-amount-queued-emails-on-Virtuozzo/details

use Data::Dumper;
$warnthres = 50000;
$critthres = 10000;
$exitstate = 0;

my @vzlist = split('\n',`sudo /usr/sbin/vzlist -o ctid`);

foreach (@vzlist)
{
        s/\s//g;
        if(/[0-9]+/)
        {
                if($_=="1"){next;}
                my $mcount = `sudo /usr/sbin/vzctl exec $_ postqueue -p 2>/dev/null | tail -n 1 | cut -d' ' -f5`;
                chop $mcount;
                if($mcount == "") {$mcount=0;}
                if($mcount > $critthres)
                {
                        $exitstate = 2;
                        $exitstring .= "$_:$mcount ";
                }
                elsif ($mcount > $warnthres)
                {
                        if($exitstate < 2)
                        {
                                $exitstate = 1;
                        }
                        $exitstring .= "$_:$mcount ";
                }

        }
}
if($exitstate == 2)
{
        print "CRITICAL: " . $exitstring . "\n";
        exit(2);
}
elsif($exitstate == 1)
{
        print "WARNING: " . $exitstring . "\n";
        exit(1);
}
else 
{       
        print "OK: No Spammers\n";
        exit(0);
}
