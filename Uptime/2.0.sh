#!/bin/bash

declare -a max
max[1]=0
max[2]=0
max[3]=0
max[4]=0

declare -a maxdown
declare -a maxup

declare -a totdown
totdown[1]=0
totdown[2]=0
totdown[3]=0
totdown[4]=0

check_final ()
{
    seconds1=`expr ${totdown[4]} % 60`
    seconds2=`expr ${totdown[4]} / 60`
    totdown[4]=$seconds1
    totdown[3]=`expr ${totdown[3]} + $seconds2`
    minutes1=`expr ${totdown[3]} % 60`
    minutes2=`expr ${totdown[3]} / 60`
    totdown[3]=$minutes1
    totdown[2]=`expr ${totdown[2]} + $minutes2`
    hours1=`expr ${totdown[2]} % 24`
    hours2=`expr ${totdown[2]} / 24`
    totdown[2]=$hours1
    totdown[1]=`expr ${totdown[1]} + $hours2`
}

dateAssign () 
{   
    max[1]=$1
    max[2]=$2
    max[3]=$3
    max[4]=$4
    max[5]=$5
    max[6]=$6
    max[7]=$7
    max[8]=$8
    max[9]=$9
}

dateAssign2 ()
{
    maxdown[1]=$1
    maxdown[2]=$2
    maxdown[3]=$3
    maxdown[4]=$4
    maxdown[5]=$5
}

dateAssign3 ()
{
    maxup[1]=$1
    maxup[2]=$2
    maxup[3]=$3
    maxup[4]=$4
    maxup[5]=$5
}

upMo=0
upD=0
upH=0
upMi=0
upS=0

up_time_from ()
{
    upMo=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n  1 | awk '{print $1}'`
    upD=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n 1 | awk '{print $2}'`
    upH=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n  1 | awk '{print $3}' | awk -F: '{print $1}'`
    upMi=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n  1 | awk '{print $3}' | awk -F: '{print $2}'`
    upS=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n 1 | awk '{print $3}' | awk -F: '{print $3}'`
}
    
cd /
cd ./var/log

len1=`cat auth.log | grep -c "System is powering down"`
len2=`cat auth.log | egrep -c "systemd-logind\[[0-9]{1,4}\]: New seat seat0"`

len=0

if ((len1>len2))
then
    len=$len2
else
    len=$len1
fi

len_boot=`expr 1 + $len`

for ((i=1 ; i<$len_boot ; i++))
do 
    upMonth=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n $i | tail -n 1 | awk '{print $1}'`
    upDate=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n $i | tail -n 1 | awk '{print $2}'`
    upHour=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $1}'`
    upMinute=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $2}'`
    upSecond=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $3}'`

    downMonth=`cat auth.log | grep "System is powering down" | head -n $i | tail -n 1 | awk '{print $1}'`
    downDate=`cat auth.log | grep "System is powering down" | head -n $i | tail -n 1 | awk '{print $2}'`
    downHour=`cat auth.log | grep "System is powering down" | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $1}'`
    downMinute=`cat auth.log | grep "System is powering down" | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $2}'`
    downSecond=`cat auth.log | grep "System is powering down" | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $3}'`
    
    diffDate=`expr $downDate - $upDate`
    diffHour=`expr $downHour - $upHour`
    diffMinute=`expr $downMinute - $upMinute`
    diffSecond=`expr $downSecond - $upSecond`

    if ((diffSecond<0)) 
    then
        diffSecond=`expr 60 + $diffSecond`
        diffMinute=`expr $diffMinute - 1`
    fi

    if ((diffMinute<0)) 
    then
        diffMinute=`expr 60 + $diffMinute`
        diffHour=`expr $diffHour - 1`
    fi

    if ((diffHour<0)) 
    then
        diffHour=`expr 24 + $diffHour`
        diffDate=`expr $diffDate - 1`
    fi

    if ((diffDate<0)) 
    then
        diffDate=`expr 31 + $diffDate`
    fi

    totdown[1]=`expr ${totdown[1]} + $diffDate`
    totdown[2]=`expr ${totdown[2]} + $diffHour`
    totdown[3]=`expr ${totdown[3]} + $diffMinute`
    totdown[4]=`expr ${totdown[4]} + $diffSecond`
    check_final

    if ((diffDate>${max[1]}))
    then
        dateAssign $diffDate $diffHour $diffMinute $diffSecond 
        dateAssign2 $downDate $downMonth $downHour $downMinute $downSecond 
        dateAssign3 $upDate $upMonth $upHour $upMinute $upSecond
    elif [ "$diffDate" -eq "${max[1]}" ]
    then
        if ((diffHour>${max[2]}))
        then
            dateAssign $diffDate $diffHour $diffMinute $diffSecond 
            dateAssign2 $downDate $downMonth $downHour $downMinute $downSecond 
            dateAssign3 $upDate $upMonth $upHour $upMinute $upSecond
        elif [ "$diffHour" -eq "${max[2]}" ]
        then
            if ((diffMinute>${max[3]}))
            then
                dateAssign $diffDate $diffHour $diffMinute $diffSecond 
                dateAssign2 $downDate $downMonth $downHour $downMinute $downSecond 
                dateAssign3 $upDate $upMonth $upHour $upMinute $upSecond
            elif [ "$diffMinute" -eq "${max[3]}" ]
            then
                if ((diffSecond>${max[4]}))
                then
                    dateAssign $diffDate $diffHour $diffMinute $diffSecond 
                    dateAssign2 $downDate $downMonth $downHour $downMinute $downSecond 
                    dateAssign3 $upDate $upMonth $upHour $upMinute $upSecond
                fi
            fi
        fi
    fi
done

check_final

echo ""
echo "Total boot occurences in the latest log file are : $len"
echo ""
echo "Max up-time is ${max[1]} days, ${max[2]} hours, ${max[3]} minutes and ${max[4]} seconds"
echo ""
echo "Corresponding up time is ${maxup[1]} ${maxup[2]} ${maxup[3]}:${maxup[4]}:${maxup[5]}"
echo ""
echo "Corresponding down time is ${maxdown[1]} ${maxdown[2]} ${maxdown[3]}:${maxdown[4]}:${maxdown[5]}"
echo ""

up_time_from 

echo "Total up time from $upD $upMo, $upH:$upMi:$upS is : ${totdown[1]} days, ${totdown[2]} hours, ${totdown[3]} minutes and ${totdown[4]} seconds"
echo ""
