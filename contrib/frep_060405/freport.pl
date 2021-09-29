#!/usr/bin/perl
#
# File is FREPORT.PL, size is 3683, create at Thu Feb 24 03:59:57 2005
#
# File is FREPORT.PL, size is 3848, changed at Tue Mar  1 23:46:16 2005
# !แฏเ ขซฅญ ฏฎจแช คใฏฎข
#
# File is FREPORT.PL, size is 4689, changed at Thu Mar  3 07:56:46 2005
# +ฎก ขซฅญ  ขฎงฌฎฆญฎแโ์ คฎก ขซ๏โ์ ข $flstrep ขโฎเฎฉ $flst2, โ ช ฆฅ คฎก ขซ๏โ์ ข
#  $frep ฏใเฆจญฃ ไ ฉซ , คฅฉแโขจฅ ฏเจ จแฏฎซ์งฎข ญจจ $flst2. ‘ฌ. $flst2
# +ฎก ขซฅญ $nof
#
# File is FREPORT.PL, size is 4923, changed at Fri Mar 11 14:47:10 2005
# +ฎก ขซฅญ $nod
# +ฎก ขซฅญ $nod2
# +ฎก ขซฅญ  ฏเฎขฅเช  ฎแญฎขญ๋ๅ ไ ฉซฎข Fpurge: $flog, $flst, $flst2
# -“ค ซจซ ็จแโชใ ไ ฉซฎข $flstrep, $frep. ‘ฌ. Usage
#
# File is FREPORT.PL, size is 4981, changed at Thu Apr  7 04:34:00 2005
#
# Authors:
# Dmitry Mikchaylov (2:5066/26)
#
# Description:
# โฎโ แชเจฏโ ฏเฅคญ งญ ็ฅญ คซ๏ ขฅคฅญจ๏ แโ โจแโจชจ ฏฎแซฅคญฅฃฎ ง ฏใแช  FPurge:
# 1. ใเฆจฅฌ ๏ คจเฅชโฎเจ๏, ฌ ชแจฌ ซ์ญ๋ฉ ขฎงเ แโ ไ ฉซ  คซ๏ คฅฉแโขจ๏: freport.lst
# 2. ใเฆจญฃ ไ ฉซ , คฅฉแโขจฅ: freport.log
#
# …แซจ ๋ ญฅ จแฏฎซ์งใฅโฅ $flst2, โฎ ง ชฎฌฅญโจเใฉโฅ ฅฃฎ.
#
# Usage:
# fpurge.exe -keys
# fpurge.exe -แ config -keys
# freport.pl
# hpt.exe post -nf "FPurge Dir Info" -keys freport.lst
# hpt.exe post -nf "FPurge Total Statistics" -keys freport.log
# del freport.lst
# del freport.log

sub clock{
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
use POSIX qw(strftime);
$data = strftime "%y-%m-%d", localtime;
$time = strftime "%H:%M:%S", localtime;
}

$flog="c:/fidom/logs/fpurge.log";
$flst="c:/fidom/misc/fpurge/fpurge.lst";
$flst2="c:/fidom/misc/fpurge/fpurge_kill.lst";
 $fdup="c:/fidom/logs/freport.dup";
 $flstrep="c:/fidom/logs/freport.lst";
   $nod="ฅโ คจเฅชโฎเจจ คซ๏ ฏใเฆจญฃ : $flst";
   $nod2="ฅโ คจเฅชโฎเจจ คซ๏ ฏใเฆจญฃ : $flst2";
 $frep="c:/fidom/logs/freport.log";
   $nof="ฅโ ไ ฉซฎข คซ๏ ฏใเฆจญฃ ";

clock($time);
if(-e"$flog"){print"#Reading $flog\n";}
  else{die"#Not reading $flog! Exit\n";}

if(-e"$flst"){print"#Reading $flst\n";}
  else{die"#Not reading $flst! Exit\n";}

if($flst2 eq ""){}
  else{
    if(-e"$flst2"){print"#Reading $flst2\n";}
      else{die"#Not reading $flst2! Exit\n";}
  }

open(LSTREP,">>","$flstrep");
printf LSTREP"%47s\n\n","Dir Purge Info";
print LSTREP"  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออัอออออป\n";
printf LSTREP"  บ %-65s ณ%-5sบ\n","จเฅชโฎเจ๏ ฏใเฆจฅฌฎฉ ไ ฉซํๅจ","ฅญ์";
print LSTREP"  ฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออุอออออน\n";
$yesdd=0;
open(LST,"$flst");
  while(<LST>)
    {
    next if(/;/io);
    next if(/^$/io);
    ~s/\|/!/io;
    if(s/(.*?)!(.*?)$/$1$2/io){$pdir=$1;$pday=$2;
      printf LSTREP"  บ %-65s ณ%-5sบ\n", $pdir, $pday;
      $yesdd=1;}
    }

if($yesdd eq 0){printf LSTREP"  บ %-65s ณ%-5sบ\n", $nod, "n/a";}

goto nex if("$flst2" eq "");

$yesdd=0;
 open(LST,"$flst2");
   while(<LST>)
     {
     ~s/\|/!/io;
     next if(/;/io);
     next if(/^$/io);
     if(s/(.*?)!(.*)\Z/$1$2/io){$pdir=$1;$pday=$2;
       printf LSTREP"  บ %-65s ณ%-5sบ\n", $pdir, $pday;
       $yesdd=1;}
     }

if($yesdd eq 0){printf LSTREP"  บ %-65s ณ%-5sบ\n", $nod2, "n/a";}

nex: print LSTREP"  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฯอออออผ\n";
close LST;
close LSTREP;

clock($time);
print"$time Start...\n";
open(REP,">>","$frep");
open(LOG,"$flog");
  while(<LOG>)
    {
    if(s/.*? (.*?-.*?-.*?) (.*?:.*?:.*?) .*/$1$2/io){$datar=$1;$timer=$2;}
    }
    printf REP"%51s\n%51s\n\n","Total Purge Statistics","($datar  $timer)";
close LOG;

print REP"  ษออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออออัออออออออออป";
printf REP"\n  บ %-8s ณ %-49s ณ %-8s บ\n","เฅฌ๏","ใเฆจญฃ ไ ฉซฎข","ฅฉแโขจฅ";
print REP"  ฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออุออออออออออน\n";
open(LOG,"$flog");
print"$time Start scan...\n";
$noff=1;
  while(<LOG>)
    {
    clock($time);
      if(s/(.*?) old file "(.*?)"/$1$2$3/io){$del=$1;$file=$2;
      $del=~tr/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/;

      $dup=0;
      dup($datar,$file);

      if($dup eq 0){
        clock($time);
        print"$time Reading $file\n";
         open(DUP,">>","$fdup");
         print"$time Error reading dupes: $file\n";
         print DUP"$datar $file\n";
         close DUP;
        printf REP"  บ %-8s ณ %-49s ณ %-8s บ\n", $timer, $file, $del;
        $noff=0;
        }
      }
      if($noff eq 1){$noff=0;
       printf REP"  บ %-8s ณ %-49s ณ %-8s บ\n",$timer,$nof,"n/a";}

}
close LOG;
print REP"  ศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออฯออออออออออผ\n";
print"$time End scan\n";
print"$time End\n";
close REP;

sub dup{
open(DUP,"$fdup");
  while(<DUP>)
    {
    if(s/^(.*?) (.*)$/$1$2/io){$datar_dup=$1;$file_dup=$2;
      if("$file_dup" eq "$file"){
      $dup=1;}
      }
    }
close DUP;
}
