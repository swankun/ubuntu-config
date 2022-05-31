# Tips for Ubuntu 64bit on Raspberry Pi 4.md

From gist.github.com/schauveau/a55eb2811fe12e8ad186d35feb788743

## Introduction 

The purpose of this gist is to give to tips for using Ubuntu 20.04 () 64bit on Raspberry Pi 4. 

## Hardware Accelerated OpenGL (Broadcom V3D)

As of today (July 22nd 2020), the latest kernel available in Focal apt is 5.4.0-1013.
Unfortunately, that kernel lacks a clock required by the v3d module. 

A proper kernel should have card0 and card1 in /sys/class/drm/ with 

    # cat /sys/class/drm/card*/device/uevent | grep DRIVER
    DRIVER=v3d
    DRIVER=vc4-drm

The solution is to manually install a more recent raspi kernel and module packages downloaded from 
http://ports.ubuntu.com/ubuntu-ports/pool/main/l/linux-raspi/. Be sure to download packages tagged 
with raspi and amd4. After dowloading, install them with   
    
    # sudo dpki -i linux*-raspi-*-amd64.deb    

Before rebooting, you also need the following line in /boot/firmware/usercfg.txt

    dtoverlay=vc4-fkms-v3d

See also https://bugs.launchpad.net/ubuntu/+source/linux-raspi/+bug/1880125

## Package python3-gpiozero is outdated

Gpiozero is a simple Python interface to GPIO devices with Raspberry Pi. 
https://gpiozero.readthedocs.io/en/stable/index.html

In Ubuntu 20.04, the current package is Gpiozero 1.4.1 which is not aware of the Raspberry Pi 4.

A more up-to-date version can be installed using pip3 (in ~/.local/ so for the current user only). 

    # sudo apt-get install python3-pip
    # pip3 install gpiozero    

The pinout tool can be used to obtain a graphical representation of the GPIOs on the board.

    # ~/.local/bin/pinout
   
## Shutdown using GPIO3 
   
On the RPi4, a power button can be installed on GPIO3. That information is easy to find. 
See for instance https://dzone.com/articles/making-your-own-rpi-power-button or https://howchoo.com/g/mwnlytk3zmm/how-to-add-a-power-button-to-your-raspberry-pi

After proper shutdown (not halt or sleep), connecting GPIO3 (ping 5) to ground (pin 6) 
will wake up the Rpi 4. That works out of the box with Ubuntu.

However, pressing the button while the RPi4 is running is supposed to trigger a KEY_POWER event
which causes Systemd to shutdown the system. That does not work by default with Ubuntu 20.04.

The first thing to do is to enable the KEY_POWER event by adding the following line to /boot/firmware/usercfg.txt

    dtoverlay=gpio-shutdown,gpio_pin=3
    
However, GPIO3 is also used by I2C so it is also necessary to disable i2c_arm in /boot/firmware/syscfg.txt 

    ...
    #dtparam=i2c_arm=on
    ...

If I2C is needed then another gpio_pin can be specified to the gpio-shutdown overlay.  

After a reboot, a new input device should be present:

    # sudo evtest
    No device specified, trying to scan all of /dev/input/event*
    Available devices:
    /dev/input/event0:      soc:shutdown_button
    ...
    Select the device event number [0-3]: 0
    
And connecting GPIO3 to ground should trigger a shutdown. 

Remark: Some keyboards can also be used to produce a KEY_POWER event. 
They won't wake up the Pi but they can be used to shutdown (or hibernate. see below) 

## Power management tuning (No Sleep) 

By default, the Systemd Logind daemon reacts to various power events emited by 
keyboards or by a button on GPIO3 (see above). 

The raspberry pi boards do not have the capability to sleep (no suspend). Any attempt 
to enter sleep or suspend mode with simply halt the pi. 

It can be a good idea to disable those modes on the pi.

    sudo systemctl mask sleep.target 
    sudo systemctl mask suspend.target 
    sudo systemctl mask hybrid-sleep.target
    
If you do not have enough swap to hybernate properly then you may want to do the same 
for the hybernate target.

Reminder: The operation can be reverted by using unmask instead of mask.

It could also be wise to edit the action associated to the various power keys in /etc/systemd/logind.conf. 
For the Pi, the relevant values are "ignore", "poweroff", "reboot", "reboot" and potentially "hybernate". See man logind.conf for more details. For instance:  

    HandlePowerKey=poweroff
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore


