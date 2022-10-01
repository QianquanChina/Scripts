#!/bin/bash
result=$(ps ax|grep -v grep|grep trayer)
echo $result
if [ "$result" == "" ]; then
    eval "trayer --edge top --width 5 --height 27 --align right --distance 10 --margin 14 --transparent true --tint 10 &"
else
    eval "killall trayer"
fi
