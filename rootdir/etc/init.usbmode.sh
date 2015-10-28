#!/system/bin/sh
# This script is used for setting USB VID/PID/functions with a delay
# in order to prevent crashes on ADB stopping/starting.

TAG=init.usbmode.sh
VID=05C6
PID=0
FUNC=`getprop sys.usb.config`
START_ADB=0
ADB_DELAY=0.01

set_pid_adb()
{
    PID=$1
    START_ADB=$2
}

case $FUNC in
    "charging")
        set_pid_adb 6768 0
        ;;
    "charging,adb")
        set_pid_adb 6768 1
        ;;
    "mtp")
        set_pid_adb 6764 0
        ;;
    "mtp,adb")
        set_pid_adb 6765 1
        ;;
    "ptp")
        set_pid_adb 6771 0
        ;;
    "ptp,adb")
        set_pid_adb 6772 1
        ;;
    "rndis")
        set_pid_adb 676A 0
        ;;
    "rndis,adb")
        set_pid_adb 6766 1
        ;;
    "midi")
        set_pid_adb 6776 0
        ;;
    "midi,adb")
        set_pid_adb 6777 1
        ;;
    "adb")
        set_pid_adb 6769 1
        ;;
esac

if [ $PID -eq 0 ]; then
    log -p e -t $TAG "Undefined USB function: $FUNC , will not do anything"
    exit 1
fi

stop adbd
sleep $ADB_DELAY
echo 0 > /sys/class/android_usb/android0/enable
echo $VID > /sys/class/android_usb/android0/idVendor
echo $PID > /sys/class/android_usb/android0/idProduct
echo $FUNC > /sys/class/android_usb/android0/functions
echo 1 > /sys/class/android_usb/android0/enable
if [ $START_ADB -eq 1 ]; then
    sleep $ADB_DELAY
    start adbd
fi
setprop sys.usb.state $FUNC

exit 0
