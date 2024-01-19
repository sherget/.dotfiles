#!/bin/bash
export PATH=/home/kwogga/.local/bin:$PATH
trayer --edge top --align right --widthtype request --expand true --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x1A1918 --expand true --heighttype pixel --height 14 --monitor 1 --padding 1 &
if [ -x /usr/bin/nm-applet ] ; then
   (sleep 1; nm-applet --sm-disable &)
fi
exec xmonad

