## This repository contains Bash-Scripts for automatic setup of the 
# 3.2 Inch TFT LCD Display Module Touch Screen For Raspberry Pi B+ B A+
### from [banggood.com] (http://www.banggood.com/3_2-Inch-TFT-LCD-Display-Module-Touch-Screen-For-Raspberry-Pi-B-B-A-p-1011516.html)


* lcd32_setup.sh is setting up the 3.2" TFT-Touch-Screen
* lcd32_uninstall.sh is removing the changes the setup-script made except leaving the backup-files remaining
* calibrate_tft-tp.sh is for calibrating the screen via xinput-calibrator


Copy all three scripts in the **same** directory. Then run "sudo bash ./lcd32_setup.sh" for setting up the touchscreen.

`pi@raspberrypi:~ $ sudo bash ./lcd32_setup.sh`

When the setup-script finished, reboot your RaspberryPi to activate the screen.
The script will create a sample calibration-file that works. But for best effort run xinput-calibrator from Menu > Preferences > Calibrate Touchscreen

To remove the settings of the setup-script run the uninstall-script.

I tested these scripts with raspbian jessie on my RaspberyPi B 2.
The setup-script adds settings to config-files (/boot/cmdline.txt /boot/config.txt /etc/rc.local) and creates a few needed config-files. Further it installs xinput-calibrator from the standard raspbian-jessie-repository. After changes in raspbian the package xserver-xorg-input-evdev is needed and the path for the configuration file is modified.
You can rerun the setup-script, if updates causing the display to work not anymore. Missing files or settings will be restored by the script, existing will remain.
Perhaps the flexfb-driver is not the best choice, but the only one I found working.
