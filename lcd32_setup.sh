#!/bin/bash
#-------------------------------------------------------------------------------
# Installation of 3.2"-Touchscreen with Raspbian 8:
#-------------------------------------------------------------------------------

# root check
if [ `id -u` -ne 0 ]; then
  1>&2 echo "error, must be run as root, exiting..."
  exit 1
fi

RUNDNAME=`dirname "$0"`
RUN_TIME=`date +%Y%m%d%H%M%S`
LOGFILE="lcd32setup.log"
echo "********************************************************************************
************ $(date --rfc-3339 seconds) Setting up TFT-Touchscreen...************" | tee -a ${LOGFILE}

# Installing driver for input devices using evdev and xinput_calibrator
NEWPKGS=(xserver-xorg-input-evdev xinput-calibrator)
for PARTSTRNG in "${NEWPKGS[@]}"
  do
    PKGTEST=`dpkg -l | grep ${PARTSTRNG}`
    if [ -z "${PKGTEST}" ] ; then
      INSTPKGS=${INSTPKGS}" "${PARTSTRNG}
    else
      echo "Package ${PARTSTRNG} is already installed" 2>&1 | tee -a ${LOGFILE}
    fi
  done
apt-get update 2>&1 | tee -a ${LOGFILE}
apt-get install ${INSTPKGS} -y 2>&1 | tee -a ${LOGFILE}

# Append string to /boot/cmdline.txt "fbcon=map:10 fbcon=font:ProFont6x11 logo.nologo"
CMDLINESTRING=" fbcon=map:10 fbcon=font:ProFont6x11 logo.nologo"
CMDLINEFILE="/boot/cmdline.txt"
CMDLINETEST=`grep "${CMDLINESTRING}" ${CMDLINEFILE}`
if [ -z "${CMDLINETEST}" ] ; then
  echo "Modifying file ${CMDLINEFILE}" 2>&1 | tee -a ${LOGFILE}
  cp -n ${CMDLINEFILE} ${CMDLINEFILE}.bak.${RUN_TIME} 2>&1 | tee -a ${LOGFILE}
  sed -i "s/$/${CMDLINESTRING}/" ${CMDLINEFILE}
else
  echo "File ${CMDLINEFILE} was already modified" 2>&1 | tee -a ${LOGFILE}
fi

# Append line to /boot/config.txt
CFGSTRING="dtoverlay=ads7846,cs=1,penirq=17,penirq_pull=2,speed=1000000,keep_vref_on=1,swapxy=0,pmax=255,xohms=60,xmin=200,xmax=3900,ymin=200,ymax=3900"
CFGFILE="/boot/config.txt"
CFGTEST=`grep "${CFGSTRING}" ${CFGFILE}`
if [ -z "${CFGTEST}" ] ; then
  echo "Modifying file ${CFGFILE}" 2>&1 | tee -a ${LOGFILE}
  cp -n ${CFGFILE} ${CFGFILE}.bak.${RUN_TIME} 2>&1 | tee -a ${LOGFILE}
  echo "${CFGSTRING}" >> ${CFGFILE}
else
  echo "File ${CFGFILE} was already modified" 2>&1 | tee -a ${LOGFILE}
fi

# Create configs for modules to load at boot time
FBTFTMODULES="/etc/modules-load.d/fbtft.conf"
if [ ! -e ${FBTFTMODULES} ] ; then
  echo "Creating file ${FBTFTMODULES}" 2>&1 | tee -a ${LOGFILE}
  touch ${FBTFTMODULES} 2>&1 | tee -a ${LOGFILE}
  echo -e "spi-bcm2835\nfbtft_device" > ${FBTFTMODULES}
else
  echo "File ${FBTFTMODULES} already exists" 2>&1 | tee -a ${LOGFILE}
fi
FBTFTOPTIONS="/etc/modprobe.d/fbtft.conf"
if [ ! -e ${FBTFTOPTIONS} ] ; then
  echo "Creating file ${FBTFTOPTIONS}" 2>&1 | tee -a ${LOGFILE}
  touch ${FBTFTOPTIONS} 2>&1 | tee -a ${LOGFILE}
  echo "options fbtft_device name=flexfb gpios=dc:22,reset:27 speed=48000000" > ${FBTFTOPTIONS}
else
  echo "File ${FBTFTOPTIONS} already exists" 2>&1 | tee -a ${LOGFILE}
fi

# Loading module flexfb delayed with a dirty trick because 
# Insert line in /etc/rc.local before "exit 0" "/sbin/modprobe flexfb width=320 height=240 buswidth=8 init=-1,0xCB,0x39,0x2C,0x00,0x34,0x02,-1,0xCF,0x00,0XC1,0X30,-1,0xE8,0x85,0x00,0x78,-1,0xEA,0x00,0x00,-1,0xED,0x64,0x03,0X12,0X81,-1,0xF7,0x20,-1,0xC0,0x23,-1,0xC1,0x10,-1,0xC5,0x3e,0x28,-1,0xC7,0x86,-1,0x36,0x28,-1,0x3A,0x55,-1,0xB1,0x00,0x18,-1,0xB6,0x08,0x82,0x27,-1,0xF2,0x00,-1,0x26,0x01,-1,0xE0,0x0F,0x31,0x2B,0x0C,0x0E,0x08,0x4E,0xF1,0x37,0x07,0x10,0x03,0x0E,0x09,0x00,-1,0XE1,0x00,0x0E,0x14,0x03,0x11,0x07,0x31,0xC1,0x48,0x08,0x0F,0x0C,0x31,0x36,0x0F,-1,0x11,-2,120,-1,0x29,-1,0x2c,-3"
RCLOCALFILE="/etc/rc.local"
RCLOCALTEST=`grep "modprobe flexfb" ${RCLOCALFILE}`
if [ -z "${RCLOCALTEST}" ] ; then
  echo "Modifying file ${RCLOCALFILE}" 2>&1 | tee -a ${LOGFILE}
  cp -n ${RCLOCALFILE} ${RCLOCALFILE}.bak.${RUN_TIME} 2>&1 | tee -a ${LOGFILE}
  sed -i '/^exit 0$/i\/sbin\/modprobe flexfb width=320 height=240 buswidth=8 init=-1,0xCB,0x39,0x2C,0x00,0x34,0x02,-1,0xCF,0x00,0XC1,0X30,-1,0xE8,0x85,0x00,0x78,-1,0xEA,0x00,0x00,-1,0xED,0x64,0x03,0X12,0X81,-1,0xF7,0x20,-1,0xC0,0x23,-1,0xC1,0x10,-1,0xC5,0x3e,0x28,-1,0xC7,0x86,-1,0x36,0x28,-1,0x3A,0x55,-1,0xB1,0x00,0x18,-1,0xB6,0x08,0x82,0x27,-1,0xF2,0x00,-1,0x26,0x01,-1,0xE0,0x0F,0x31,0x2B,0x0C,0x0E,0x08,0x4E,0xF1,0x37,0x07,0x10,0x03,0x0E,0x09,0x00,-1,0XE1,0x00,0x0E,0x14,0x03,0x11,0x07,0x31,0xC1,0x48,0x08,0x0F,0x0C,0x31,0x36,0x0F,-1,0x11,-2,120,-1,0x29,-1,0x2c,-3' ${RCLOCALFILE} 2>&1 | tee -a ${LOGFILE}
else
  echo "File ${RCLOCALFILE} was already modified" 2>&1 | tee -a ${LOGFILE}
fi

# Change Frame-Buffer-Display from 0 to 1 in /usr/share/X11/xorg.conf.d/99-fbturbo.conf
FBTURBOCONF="/usr/share/X11/xorg.conf.d/99-fbturbo.conf"
if [ -e ${FBTURBOCONF} ] ; then
  echo "Modifying file ${FBTURBOCONF}" 2>&1 | tee -a ${LOGFILE}
  sed -i 's/\/dev\/fb0/\/dev\/fb1/' ${FBTURBOCONF} 2>&1 | tee -a ${LOGFILE}
  InputClassTEST=`grep "Section \"InputClass\"" ${FBTURBOCONF}`
  if [ -z "${InputClassTEST}" ] ; then
    echo -e "Section \"InputClass\"
        Identifier \"evdev touchscreen catchall\"
        MatchIsTouchscreen \"on\"
        MatchDevicePath \"/dev/input/event*\"
        Driver \"evdev\"
        Option \"GrabDevice\" \"True\"
        Option \"SwapAxes\" \"True\"
        Option \"InvertY\" \"false\"
        Option \"InvertX\" \"false\"
EndSection" >> ${FBTURBOCONF}
  else
    echo "File ${FBTURBOCONF} was already modified" 2>&1 | tee -a ${LOGFILE}
  fi
else
  echo -e "\e[01;31mFile ${FBTURBOCONF} not found. Not configuring X11-Frame-Buffer-Device\e[00m" 2>&1 | tee -a ${LOGFILE}
  echo "To activate your TFT-Display reboot your RaspberryPi."
  exit 1
fi

# Copying calibration script, setting permissions and changing path in link file
CALSCRIPT="calibrate_tft-tp.sh"
XSESSIONDPATH="/etc/X11/Xsession.d/"
if [ ! -e ${XSESSIONDPATH}${CALSCRIPT} ] ; then
  echo "Copying file ${XSESSIONDPATH}${CALSCRIPT}" 2>&1 | tee -a ${LOGFILE}
  cp -n ${RUNDNAME}/${CALSCRIPT} ${XSESSIONDPATH}${CALSCRIPT} 2>&1 | tee -a ${LOGFILE}
  chmod 755 ${XSESSIONDPATH}${CALSCRIPT} 2>&1 | tee -a ${LOGFILE}
else
  echo "File ${XSESSIONDPATH}${CALSCRIPT} already exists" 2>&1 | tee -a ${LOGFILE}
fi
sed -i 's/Exec=\/bin\/sh -c \"xinput_calibrator; cat\"/Exec=sudo \/etc\/X11\/Xsession.d\/calibrate_tft-tp.sh/' /usr/share/applications/xinput_calibrator.desktop 2>&1 | tee -a ${LOGFILE}

# Checking if calibration file exists, otherwise creating a sample calibration file
#CALFILE="/etc/X11/xorg.conf.d/99-calibration.conf"
CALFILE="99-calibration.conf"
#XORGCONFPATH="/etc/X11/xorg.conf.d/"
XORGCONFPATH="/usr/share/X11/xorg.conf.d/"
if [ ! -e ${XORGCONFPATH}${CALFILE} ] ; then
  if [ ! -e ${XORGCONFPATH} ] ; then
    echo "Configuration directory ${XORGCONFPATH} not found, creating it" 2>&1 | tee -a ${LOGFILE}
    mkdir -p ${XORGCONFPATH} 2>&1 | tee -a ${LOGFILE}
  else
    echo "Configuration directory ${XORGCONFPATH} already exists" 2>&1 | tee -a ${LOGFILE}
  fi
  echo "Creating ${XORGCONFPATH}${CALFILE} with sample values" 2>&1 | tee -a ${LOGFILE}
  touch ${XORGCONFPATH}${CALFILE} 2>&1 | tee -a ${LOGFILE}
  echo -e "Section \"InputClass\"
        Identifier      \"calibration\"
        MatchProduct    \"ADS7846 Touchscreen\"
        Option  \"Calibration\"   \"200 3800 3800 200\"
        Option  \"SwapAxes\"      \"1\"
EndSection" > ${XORGCONFPATH}${CALFILE}
  echo -e "Please \e[01;32mcalibrate\e[00m your touchpanel for best effort."
else
  echo "File ${XORGCONFPATH}${CALFILE} already exists" 2>&1 | tee -a ${LOGFILE}
fi

echo -e "To activate your TFT-Display and calibrate your touchpanel \e[01;32mreboot\e[00m your RaspberryPi."

echo "
******* $(date --rfc-3339 seconds) Finished setting up TFT-Touchscreen... *******
********************************************************************************
" | tee -a ${LOGFILE}
exit 0
