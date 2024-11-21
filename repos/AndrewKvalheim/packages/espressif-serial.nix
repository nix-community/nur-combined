{ pkgs, ... }:

let
  inherit (pkgs) writeTextDir;
in
writeTextDir "etc/udev/rules.d/70-espressif-serial.rules" ''
  # Espressif USB Serial/JTAG Controller
  SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", TAG+="uaccess"
''
