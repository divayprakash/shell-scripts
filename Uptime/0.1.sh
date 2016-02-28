#!/bin/bash

declare -a max
max[0]=0
max[1]=0
max[2]=0
max[3]=0

declare -a maxup

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
    maxup[1]=$1
    maxup[2]=$2
    maxup[3]=$3
    maxup[4]=$4
    maxup[5]=$5
}

cd ../..
cd ../..
mkdir ./home/divay/Desktop/prac1
cd ../..
cd ./var/log
cat auth.log | grep "System is powering down" > /home/divay/Desktop/prac1/down.txt
cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" > /home/divay/Desktop/prac1/up.txt
cd ../..
cd ./home/divay/Desktop/prac1

len1=`grep -c "s" down.txt`
len2=`grep -c "s" up.txt`

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
    upMonth=`cat up.txt | head -n $i | tail -n 1 | awk '{print $1}'`
    #echo $upMonth
    upDate=`cat up.txt | head -n $i | tail -n 1 | awk '{print $2}'`
    #echo $upDate
    upHour=`cat up.txt | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $1}'`
    #echo $upHour
    upMinute=`cat up.txt | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $2}'`
    #echo $upMinute
    upSecond=`cat up.txt | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $3}'`
    #echo $upSecond    

    downMonth=`cat down.txt | head -n $i | tail -n 1 | awk '{print $1}'`
    #echo $downMonth
    downDate=`cat down.txt | head -n $i | tail -n 1 | awk '{print $2}'`
    #echo $downDate
    downHour=`cat down.txt | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $1}'`
    #echo $downHour
    downMinute=`cat down.txt | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $2}'`
    #echo $downMinute
    downSecond=`cat down.txt | head -n $i | tail -n 1 | awk '{print $3}' | awk -F: '{print $3}'`
    #echo $downSecond

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

    if ((diffDate>${max[1]}))
    then
        dateAssign $diffDate $diffHour $diffMinute $diffSecond $downDate $downMonth $downHour $downMinute $downSecond 
        dateAssign2 $upDate $upMonth $upHour $upMinute $upSecond
    elif [ "$diffDate" -eq "${max[1]}" ]
    then
        if ((diffHour>${max[2]}))
        then
            dateAssign $diffDate $diffHour $diffMinute $diffSecond $downDate $downMonth $downHour $downMinute $downSecond 
            dateAssign2 $upDate $upMonth $upHour $upMinute $upSecond
        elif [ "$diffHour" -eq "${max[2]}" ]
        then
            if ((diffMinute>${max[3]}))
            then
                dateAssign $diffDate $diffHour $diffMinute $diffSecond $downDate $downMonth $downHour $downMinute $downSecond 
                dateAssign2 $upDate $upMonth $upHour $upMinute $upSecond
            elif [ "$diffMinute" -eq "${max[3]}" ]
            then
                if ((diffSecond>${max[4]}))
                then
                    dateAssign $diffDate $diffHour $diffMinute $diffSecond $downDate $downMonth $downHour $downMinute $downSecond 
                    dateAssign2 $upDate $upMonth $upHour $upMinute $upSecond
                fi
            fi
        fi
    fi

    #echo "Time diff between downTime and upTime is :"
    #echo "Number of days: "$diffDate
    #echo "Number of hours: "$diffHour
    #echo "Number of minutes: "$diffMinute
    #echo "Number of seconds: "$diffSecond
    #echo ${max[@]}
done

cd ../..
cd ../..
rm -rf ./home/divay/Desktop/prac1

echo ""
echo "Total boot occurences in the latest log file are : $len"
echo "Max down-time is ${max[1]} days, ${max[2]} hours, ${max[3]} minutes and ${max[4]} seconds"
echo "Corresponding down time is ${max[5]} ${max[6]} ${max[7]}:${max[8]}:${max[9]}"
echo "Corresponding up time is ${maxup[1]} ${maxup[2]} ${maxup[3]}:${maxup[4]}:${maxup[5]}"
echo ""
