#! /bin/sh

rebootDate=`last | grep reboot | head -5 | tail -1 | awk '{print $7}'`
rebootTime=`last | grep reboot | head -5 | tail -1 | awk '{print $8}'`

echo "Reboot Time is"
echo "Date - "$rebootDate
echo "Time - "$rebootTime

rebootH=`echo $rebootTime | awk -F: '{print $1}'`
rebootM=`echo $rebootTime | awk -F: '{print $2}'`

currDay=`date | awk '{print $3}'`
currH=`date | awk '{print $4}' | awk -F: '{print $1}'`
currM=`date | awk '{print $4}' | awk -F: '{print $2}'`

echo "Current Time is"
echo "Date - "$currDay
echo "Time - "$currH":"$currM

dayDiff=`expr $currDay - $rebootDate`
hourDiff=`expr $currH - $rebootH`
minDiff=`expr $currM - $rebootM`

if [ $minDiff -lt 0 ] 
then
  minDiff=`expr 60 + $minDiff`
  hourDiff=`expr $hourDiff - 1`
fi

if [ $hourDiff -lt 0 ] 
then
  hourDiff=`expr 24 + $hourDiff`
  dayDiff=`expr $dayDiff - 1`
fi

if [ $dayDiff -lt 0 ] 
then
  dayDiff=`expr 31 +$dayDiff`
fi


echo "----Time Difference between current time and 5th reboot from now is----"
echo "Number of days: "$dayDiff
echo "Number of hours: "$hourDiff
echo "Number of minutes: "$minDiff

