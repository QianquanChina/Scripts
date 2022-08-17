#!/bin/bash

function get_bytes {
    # Find active network interface
    interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
    line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
    eval $line
    now=$(date +%s%N)
}

function get_velocity {
    value=$1
    old_value=$2
    now=$3

    timediff=$(($now - $old_time))
    velKB=$(echo "1000000000*($value-$old_value)/1024/$timediff" | bc)
    if test "$velKB" -gt 1024
    then
        echo $(echo "$velKB/1024" | bc)MB/s
    else
        echo ${velKB}KB/s
    fi
}

get_bytes
old_received_bytes=$received_bytes
old_transmitted_bytes=$transmitted_bytes
old_time=$now

check_connect(){

    interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
    if [ "$interface" = "" ]; then
        printf "睊"
    else
        line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
        sped=$(echo $line | sed -r "s/.*=(.*).*/\1/")
        if [ "$sped" -eq 0 ]; then
            printf "睊"
        else
            printf "直 "
            name=$(iw wlp3s0 info | awk '/ssid/' | awk '{print $2}')
            printf "%s" "$name"
        fi
    fi
}

get_battery_charging_status() {

    if $(acpi -b | grep --quiet Discharging)
    then
        echo "ﮤ";
    else # acpi can give Unknown or Charging if charging, https://unix.stackexchange.com/questions/203741/lenovo-t440s-battery-status-unknown-but-charging
        echo "";
    fi
}

get_battery_combined_percent() {

    # get charge of all batteries, combine them
    total_charge=$(expr $(acpi -b | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc));

    # get amount of batteries in the device
    battery_number=$(acpi -b | wc -l);

    percent=$(expr $total_charge / $battery_number);

    echo $percent;
}

get_time_until_charged() {

    # parses acpitool's battery info for the remaining charge of all batteries and sums them up
    sum_remaining_charge=$(acpitool -B | grep -E 'Remaining capacity' | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc);

    # finds the rate at which the batteries being drained at
    present_rate=$(acpitool -B | grep -E 'Present rate' | awk '{print $4}' | grep -Eo "[0-9]+" | paste -sd+ | bc);

    # divides current charge by the rate at which it's falling, then converts it into seconds for `date`
    seconds=$(bc <<< "scale = 10; ($sum_remaining_charge / $present_rate) * 3600");

    # prettifies the seconds into h:mm:ss format
    #pretty_time=$(date -u  ${seconds} );
    pretty_time=$(date '+%Y-%m-%d %H:%M:%S');

    echo $pretty_time;
}

print_bat(){
    echo "$(get_battery_charging_status) $(get_battery_combined_percent)%, $(get_time_until_charged )";
}

print_date(){
    date '+%Y-%m-%d %H:%M:%S'
}

dwm_alsa () {
    VOL=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
    VOLSTAT=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\] \[(.*)\]/\2/")
    printf "%s" "$SEP1"
    if [ "$VOL" -eq 0 ] || [ "$VOLSTAT" = "off" ]; then
        printf "婢"
    else
        printf "墳 %s%%" "$VOL"
    fi
    printf "%s\n" "$SEP2"
}

get_bytes
vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)

xsetroot -name " $(check_connect) $vel_recv $vel_trans $(dwm_alsa) [ $(print_bat) ] Grace"

# Update old values to perform new calculations
old_received_bytes=$received_bytes
old_transmitted_bytes=$transmitted_bytes
old_time=$now

exit 0

