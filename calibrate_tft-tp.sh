#!/bin/bash

CALFILE="/etc/X11/xorg.conf.d/99-calibration.conf"
CALDATA=`xinput_calibrator --precalib  200 3800 3800 200 | grep -A 10 InputClass`
if [ ! -z "$CALDATA" ] ; then
  echo "$CALDATA" > $CALFILE
  echo "Calibration data stored in $CALFILE"
fi

