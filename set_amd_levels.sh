#!/bin/bash

# "01234567" => ~123 S/s
# "0123456"  => ~120 S/s
# "012345"   => ~116 S/s
# "01234"    => ~112 S/s
# "0123"     => ~105 S/s

if [[ -f $RIGRC ]]
then
    source $RIGRC
elif [[ -f ${RIGHOME}/.rigrc ]]
then
    source ${RIGHOME}/.rigrc
else
    source ${HOME}/.rigrc
fi

if [[ $RIG_PERFORMANCE_MODE ]]
then
    PERF=$RIG_PERFORMANCE_MODE
else
    PERF=normal
fi
force_perf_level="manual"

case $PERF in
    auto)
        force_perf_level="auto"    # TODO test this
        fan=255
        ;;
    custom)
        sclk[0]="01234567"
        sclk[2]="0123456"
        sclk[3]="01234567"
        sclk[4]="01234567"
        #fans=255
        fans=255
        fan[0]=240
        fan[2]=240
        fan[3]=240
        fan[4]=180
#        fans=180
        ;;
    custom-2)
        sclk[0]="0123456"
        sclk[2]="012345"
        sclk[3]="0123456"
        sclk[4]="01234567"
        #fans=255
        fans=160
        ;;
    full)
        sclk[0]="01234567"
        sclk[2]="01234567"
        sclk[3]="01234567"
        sclk[4]="01234567"
        fans=255
        ;;
    full-low-noise)
        sclk[0]="01234567"
        sclk[2]="01234567"
        sclk[3]="01234567"
        sclk[4]="01234567"
        #fans=200
        fans=180
        ;;
    normal)
        #
        sclk[0]="0123456"
        sclk[2]="01234"
        sclk[3]="012345"
        fans=220
        ;;
    normal-full-fans)
        # ~XXX S/s
        sclk[0]="0123456"
        sclk[2]="01234"
        sclk[3]="012345"
        sclk[4]="01234567"
        fans=255
        ;;
    normal-room)
        # Rig in room, ~480 S/s
        sclk[0]="01234567"
        sclk[2]="012345"
        sclk[3]="0123456"
        sclk[4]="01234567"
        fans=255
        ;;
    night)
        # Night mode, ~460 S/s
        sclk[0]="012345"
        sclk[2]="0123"
        sclk[3]="012345"
        sclk[4]="0123456"
        fans=160
        ;;
    night-storage-floor)
        # 0.3.4: 45-47-46-45 °C, ~479 S/s
        # 0.5.0: 48-48-46-45 °C
        sclk[0]="01234567"
        sclk[2]="0123456"
        sclk[3]="0123456"
        sclk[4]="01234567"
        fans=160
        #fan[0]=240
        fan[2]=180
        fan[3]=180
        #fan[4]=180
        ;;
    quiet)
        sclk[0]="01234"
        sclk[2]="0123"
        sclk[3]="01234"
        fans=140
        ;;
    *)
        echo "Unknown performance mode: $PERF. Exiting."
        exit 1;
esac

# Sometimes card0 becames card1 after reboot, making sure it gets the right
# settings anyway
sclk[1]=${sclk[0]}
fan[1]=${fan[0]}

echo "Setting performance mode to: $PERF"

set_levels()
{
    card=card$1
    hwmon=hwmon$2
    sclk=${sclk[$1]}
    if [[ ${fan[$1]} ]]
    then
        fan=${fan[$1]}
    else
        fan=$fans
    fi

    echo $card $hwmon $force_perf_level $sclk $fan

    echo $force_perf_level > /sys/class/drm/${card}/device/power_dpm_force_performance_level
    echo $sclk > /sys/class/drm/${card}/device/pp_dpm_sclk 
    echo $fan > /sys/class/drm/${card}/device/hwmon/${hwmon}/pwm1;

#    echo manual > /sys/class/drm/card0/device/power_dpm_force_performance_level
#    echo 012345 > /sys/class/drm/card0/device/pp_dpm_sclk 
#    echo 255 > /sys/class/drm/card3/device/hwmon/hwmon2/pwm1;
}

hwmon_id=0
for i in 0 1 2 3 4 5 6 7
do
    if [ -f /sys/class/drm/card${i}/device/hwmon/hwmon?/pwm1 ]
    then
        #echo $i
        set_levels $i $hwmon_id
        hwmon_id=$((hwmon_id + 1))
    fi
done
