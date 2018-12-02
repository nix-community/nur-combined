# Common configuration between machines

{ config, pkgs, options, ... }:
{
services.udev = {
extraRules = ''
# udev rules for Adafruit's boards like Trinket, Gemma, Flora, Bluefruit Micro, etc.
#
# Copy this file to the location of your distribution's udev rules, for example on Ubuntu:
#   sudo cp adafruit-trinket.rules /etc/udev/rules.d/
# Then reload udev configuration by executing:
#   sudo reload udev
# Or if that doesn't work try:
#   sudo udevadm control --reload-rules
#   sudo udevadm trigger

# Rule to make Trinket/Pro Trinket/Gemma/Flora programmable without running Arduino as root.
# Tested with Ubuntu 14.04 and 12.04.  Other distributions might need to update GROUP="dialout"
# to another group value like "users".
SUBSYSTEM=="usb", ATTRS{idProduct}=="0c9f", ATTRS{idVendor}=="1781", MODE="0660", GROUP="dialout"

# Rule to blacklist Adafruit USB CDC boards from being manipulated by ModemManager.
# Fixes issue with hanging references to /dev/ttyACM* devices on Ubuntu 15.04.
ATTRS{idVendor}=="239a", ENV{ID_MM_DEVICE_IGNORE}="1"

# Circuit Playground
# General rule (actually covers all Adafruit boards with same USB VID):
ATTRS{idVendor}=="239a", MODE="0660", GROUP="dialout"
# pedantic rule: normal operation
#SUBSYSTEM=="tty", ATTRS{idProduct}=="8011", ATTRS{idVendor}=="239a", MODE="0660", GROUP="adm"
# pedentic rule: bootloader/programming
#SUBSYSTEM=="tty", ATTRS{idProduct}=="0011", ATTRS{idVendor}=="239a", MODE="0660", GROUP="adm"

'';
};
}
