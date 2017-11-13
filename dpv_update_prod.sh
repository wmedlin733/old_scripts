#!/bin/bash
### wals prod servers dpv update script

PATH=/bin
LD_LIBRARY_PATH=/opt/mgicoa/lib:/usr/lib
export LD_LIBRARY_PATH
LOG=/home/amsauto/bin/updatedpv_`hostname`.log

### check for tag file
cd /home/amsauto/data
[ -f verified.tag ] || exit 1
echo "########################################" >> $LOG
echo "`date`:  new data found" >> $LOG

### backup data
rm -rf /opt/mgicoa/amsdata.bak
mv -f /opt/mgicoa/amsdata /opt/mgicoa/amsdata.bak
mkdir /opt/mgicoa/amsdata
cp -p /opt/mgicoa/amsdata.bak/dpv* /opt/mgicoa/amsdata &
cp -p /opt/mgicoa/amsdata.bak/dsadrfle.* /opt/mgicoa/amsdata &
cp -p /opt/mgicoa/amsdata.bak/dszipfle.* /opt/mgicoa/amsdata &
cp -p /opt/mgicoa/amsdata.bak/libz4sun.so /opt/mgicoa/amsdata &
cp -p /opt/mgicoa/amsdata.bak/sample* /opt/mgicoa/amsdata &
cp -p /opt/mgicoa/amsdata.bak/z4* /opt/mgicoa/amsdata &
wait
echo "`date`:  data backed up.  updating . . . " >> $LOG

### update data
cp * /opt/mgicoa/amsdata
rm -f /opt/mgicoa/amsdata/verified.tag

### restart daemon and test
cd /opt/mgicoa/amsdata
./dpv2s -k 2>> $LOG
[ -f /tmp/dpv.pid ] && kill -9 `cat /tmp/dpv.pid` >/dev/null
./dpv2s >> $LOG
cd /home/amsauto/bin
./dpv_test1.e
ONE=$?
./dpv_test2.e
TWO=$?
[ $ONE != 99 ] || [ $TWO != 99 ] && {
  echo "`date`:  port verify failed on `hostname`" >> $LOG
  echo "" | mailx -s "port verify failed on `hostname` at `date`" 9014774388@my2way.com
  exit 2
}
echo "`date`:  dpv2s tested successfully" >> $LOG
echo "`date`:  dpv2s restarted. PID: `cat /tmp/dpv.pid`. Time: `ps -ef | grep dpv2s | grep -v grep | awk '{print $5}'`" >> $LOG
echo "" | mailx -s "`hostname` dpv data updated at `date`" 9014774388@my2way.com
exit 0
