#!/bin/bash

show_card()
{
    id=$1
    card=card$id

    echo "======= Card $id ======="
    echo "Fan speed:  " \
        $(bc <<< "scale=2; $(cat /sys/class/drm/${card}/device/hwmon/hwmon?/pwm1) * 100 / \
        $(cat /sys/class/drm/${card}/device/hwmon/hwmon?/pwm1_max)") \
        "%" \
        " ("$(cat /sys/class/drm/${card}/device/hwmon/hwmon?/pwm1)")"
    echo -e "Temperature:" \
        $(bc <<< "scale=2; $(cat /sys/class/drm/${card}/device/hwmon/hwmon?/temp1_input) / 1000") \
        "°C"
    sudo cat /sys/kernel/debug/dri/${id}/amdgpu_pm_info | grep -F "["
    #echo
}

show_gpu_stats()
{
    for i in 0 1 2 3 4 5 6 7
    do
        if [ -f /sys/class/drm/card${i}/device/hwmon/hwmon?/pwm1 ]
        then
            #echo $i
            show_card $i
        fi
    done
}

show_rig_status()
{
    echo "===== $(hostname) status: ====="
    awk '   { if ($1 < 33000 ) fail++; } 
        END { if (!fail) printf "|         OK         |";
              else printf ">  " fail " GPU(s) down!!!  <" }' \
        /sys/class/drm/card?/device/hwmon/hwmon?/temp1_input
    echo
    echo "----------------------"
    echo -n "T: "
    awk '{ if (NR > 1) prefix=" | "; printf prefix $0/1000 }' /sys/class/drm/card?/device/hwmon/hwmon?/temp1_input
    echo " |"
    echo "======================"
    echo Uptime: $(uptime -p)
    echo Perf. mode: $(awk -F= '/^RIG_PERFORMANCE_MODE/ {print $2}' ${HOME}/.rigrc)
    echo Hashrate: $(tail -n15 ${HOME}/log/mine.log | awk '/\[Total\]/ { if ($17) rate=$17" "$18" "$19; else rate=$12" "$13" "$14} END {print rate}')
    echo
}

show_rig_status
show_gpu_stats

