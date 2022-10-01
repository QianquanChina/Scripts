#!/bin/bash
#xrandr --output HDMI-1-0 --mode 2560x1440 --rate 144 --output eDP-1 --off
xrandr --output HDMI-1-0 --mode 1920x1080 --rate 144 --output eDP-1 --off
/bin/bash ~/Scripts/dwm/dwm_refresh.sh &
feh --bg-scale --no-fehbg ~/Downloads/BackGround/3.png
fcitx5 &
sleep 1 && picom --experimental-backends --config ~/Scripts/dwm/config/picom.conf &
# xcompmgr &
~/Scripts/dwm/autostart_wait.sh
