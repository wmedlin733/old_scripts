#!/bin/bash
# CDCI POC:  1-864-882-0863 "Craig" (working hours only)
# Do not edit this script without permission!

PATH=/bin:/usr/bin
LOG=/var/log/cdciftp.log
PASS_MAIL="9014774388@my2way.com william.medlin@usps.gov 9017214675@page.metrocall.com valenta.petty@usps.gov barbara.e.reilly@usps.gov brobins9@email.usps.gov jsharkey@email.usps.gov hoangv@imagitas.com uspsauto@commdata.com corrae@imagitas.com yconston@usps.gov"
FAIL_MAIL="9014774388@my2way.com william.medlin@usps.gov 9017214675@page.metrocall.com valenta.petty@usps.gov barbara.e.reilly@usps.gov brobins9@email.usps.gov jsharkey@email.usps.gov hoangv@imagitas.com corrae@imagitas.com yconston@usps.gov"

cd /home/cdci
### checks for work.tag to eliminate script from running over itself.
[ -f work.tag ] && exit
### check for main.tag, if not there, exit. 
[ ! -f main.tag ] && exit
### check for "done" inside main.tag, if present, job is done, so exit.
grep -q done main.tag && exit
### get start time for mf done file
START=`date`
### so, no work.tag, we got an empty main.tag, we are gtg to encrypt/send.
echo ############################## >> $LOG
echo `date`:  CDCI job started >> $LOG
### see if encrypted file already exists.  if not, encrypt.
[ ! -f cddata.zip.gpg ] && {
    echo cddata.zip is being encrypted to cddata.zip.gpg >> $LOG
    gpg --always-trust --batch -o cddata.zip.gpg -r "CDCI Sourcelink" -e cddata.zip >> $LOG
    [ $? -ne "0" ] && {
        echo `date`:  encryption failed >> $LOG
        echo "" | mail -s "CDCI encryption failed at `date`" $FAIL_MAIL
        rm work.tag
        exit 1
    }
    echo `date`:  encryption successful >> $LOG
}
### send encrypted file
/usr/local/bin/cdci_sftp.sh >> $LOG
[ $? -ne "0" ] && {
    echo `date`:  sftp failed >> $LOG
    echo "" | mail -s "CDCI sftp failed at `date`" $FAIL_MAIL
    rm work.tag
    exit 1
}
rm cddata.zip.gpg
echo done > main.tag
echo "" | mail -s "CDCI Job Success at `date`" $PASS_MAIL 
echo `date`:  CDCI job completed >> $LOG
### creates done file for mainframe
echo $START - Job started  >  cddone.status
echo `date` - Job finished >> cddone.status
chmod 777 cddone.status
rm work.tag
