#!/bin/bash
#-------------------------------------------------------------------------------
# Deinstallation of 3.2"-Touchscreens with Raspbian 8:
#-------------------------------------------------------------------------------

LOG="lcd32uninstall.log"
echo "********************************************************************************
*********** $(date --rfc-3339 seconds) Uninstalling TFT-Touchscreen...***********" | tee -a $LOG

# Change fb-display from 1 to 0 in /usr/share/X11/xorg.conf.d/99-fbturbo.conf
sed -i 's/\/dev\/fb1/\/dev\/fb0/' /usr/share/X11/xorg.conf.d/99-fbturbo.conf 2>&1 | tee -a $LOG

XCALIBPGK="xinput-calibrator"
XCALIBPGKTEST=`dpkg -l | grep $XCALIBPGK`
if [ ! -z "$XCALIBPGKTEST" ] ; then
  echo "Uninstalling package $XCALIBPGK" 2>&1 | tee -a $LOG
  apt-get purge xinput-calibrator -y 2>&1 | tee -a $LOG
else
  echo "Package $XCALIBPGK is not installed"
fi

echo "Removing files" 2>&1 | tee -a $LOG
rm -f /etc/X11/Xsession.d/calibrate_tft-tp.sh 2>&1 | tee -a $LOG
rm -f /etc/X11/xorg.conf.d/99-calibration.conf 2>&1 | tee -a $LOG
rm -f /etc/modules-load.d/fbtft.conf 2>&1 | tee -a $LOG
rm -f /etc/modprobe.d/fbtft.conf 2>&1 | tee -a $LOG
sed -i '/\/sbin\/modprobe flexfb width=320 height=240 buswidth=8 init=-1,0xCB,0x39,0x2C,0x00,0x34,0x02,-1,0xCF,0x00,0XC1,0X30,-1,0xE8,0x85,0x00,0x78,-1,0xEA,0x00,0x00,-1,0xED,0x64,0x03,0X12,0X81,-1,0xF7,0x20,-1,0xC0,0x23,-1,0xC1,0x10,-1,0xC5,0x3e,0x28,-1,0xC7,0x86,-1,0x36,0x28,-1,0x3A,0x55,-1,0xB1,0x00,0x18,-1,0xB6,0x08,0x82,0x27,-1,0xF2,0x00,-1,0x26,0x01,-1,0xE0,0x0F,0x31,0x2B,0x0C,0x0E,0x08,0x4E,0xF1,0x37,0x07,0x10,0x03,0x0E,0x09,0x00,-1,0XE1,0x00,0x0E,0x14,0x03,0x11,0x07,0x31,0xC1,0x48,0x08,0x0F,0x0C,0x31,0x36,0x0F,-1,0x11,-2,120,-1,0x29,-1,0x2c,-3/d' /etc/rc.local 2>&1 | tee -a $LOG
sed -i '/dtoverlay=ads7846,cs=1,penirq=17,penirq_pull=2,speed=1000000,keep_vref_on=1,swapxy=0,pmax=255,xohms=60,xmin=200,xmax=3900,ymin=200,ymax=3900/d' /boot/config.txt 2>&1 | tee -a $LOG
sed -i 's/ fbcon=map:10 fbcon=fon:ProFont6x11 logo.nologo//' /boot/cmdline.txt 2>&1 | tee -a $LOG

echo "
****** $(date --rfc-3339 seconds) Finished uninstalling TFT-Touchscreen... ******
********************************************************************************
" | tee -a $LOG

exit 0

