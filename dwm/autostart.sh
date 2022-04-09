#!/bin/bash 
#xrandr --output HDMI-1-0 --mode 2560x1440 --rate 144 --output eDP-1 --off
xrandr --output HDMI-1-0 --mode 1920x1080 --rate 144 --output eDP-1 --off
/bin/bash ~/Scripts/dwm/dwm_refresh.sh &
feh --bg-scale 1-no-fehbg ~/Downloads/BackGround/1.png
fcitx5 &
sleep 1 && picom --config ~/Scripts/dwm/config/compton.conf &
# xcompmgr &
~/Scripts/dwm/autostart_wait.sh
