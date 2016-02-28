#!/bin/bash

month_array=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
global_temp_var=0

monthAssign ()
{   
    declare -a temp1
    temp1=$1
    for ((i=0 ; i<13 ; i++))
    do
    	declare -a temp2
    	temp2=${month_array[$i]}
    	if [ "${temp1[0]}" -eq "${temp2[0]}" ]
        then
            if [ "${temp1[1]}" -eq "${temp2[1]}" ]
            then
                if [ "${temp1[2]}" -eq "${temp2[2]}" ]
                then
            		global_temp_var=$i
            	fi
            fi	
        fi  
    done
}

cd /
cd ./var/log
upMonth=`cat auth.log | egrep "systemd-logind\[[0-9]{1,4}\]: New seat seat0" | head -n 1 | tail -n 1 | awk '{print $1}'`
monthAssign $upMonth
upMonth=`expr $global_temp_var + 1`
echo $upMonth