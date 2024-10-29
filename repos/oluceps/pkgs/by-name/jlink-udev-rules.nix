{ stdenv, writeText }:
## Usage
# In NixOS, simply add this package to services.udev.packages:
#   services.udev.packages = [ pkgs.opensk-udev-rules ];
let
  rule = writeText "jlink-udev-rules" ''
    #
    # This file is going to be stored at /etc/udev/rules.d on installation of the J-Link package
    # It makes sure that non-superuser have access to the connected J-Links, so JLinkExe etc. can be executed as non-superuser and can work with J-Link
    #
    #
    # Matches are AND combined, meaning: a==b,c==d,do stuff
    # results in:                        if (a == b) && (c == d) -> do stuff
    #
    ACTION!="add", SUBSYSTEM!="usb_device", GOTO="jlink_rules_end"
    #
    # Give all users read and write access.
    # Note: NOT all combinations are supported by J-Link right now. Some are reserved for future use, but already added here
    #
    # ATTR{filename}
    #                  Match sysfs attribute values of the event device. Trailing
    #                  whitespace in the attribute values is ignored unless the specified
    #                  match value itself contains trailing whitespace.
    #
    # ATTRS{filename}
    #                  Search the devpath upwards for a device with matching sysfs
    #                  attribute values. If multiple ATTRS matches are specified, all of
    #                  them must match on the same device. Trailing whitespace in the
    #                  attribute values is ignored unless the specified match value itself
    #                  contains trailing whitespace.
    #
    # How to find out about udev attributes of device:
    # Connect J-Link to PC
    # Terminal: cat /var/log/syslog
    # Find path to where J-Link device has been "mounted"
    # sudo udevadm info --query=all --attribute-walk --path=<PathExtractedFromSyslog>
    # sudo udevadm info --attribute-walk /dev/bus/usb/<Bus>/<Device> (extract <Bus> and <Device> from "lsusb")
    # Reload udev rules after rules file change:
    #   sudo udevadm control --reload-rules
    #   sudo udevadm trigger
    #
    # [old format]
    # 0x0101 - J-Link (default)                 | Flasher STM8 | Flasher ARM | Flasher 5 PRO
    # 0x0102 - J-Link USBAddr = 1 (obsolete)
    # 0x0103 - J-Link USBAddr = 2 (obsolete)
    # 0x0104 - J-Link USBAddr = 3 (obsolete)
    # 0x0105 - CDC + J-Link
    # 0x0106 - CDC
    # 0x0107 - RNDIS  + J-Link
    # 0x0108 - J-Link + MSD
    #
    ATTR{idProduct}=="0101", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="0102", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="0103", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="0104", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="0105", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="0107", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="0108", ATTR{idVendor}=="1366", MODE="666"
    #
    # Make sure that J-Links are not captured by modem manager service
    # as this service would try detect J-Link as a modem and send AT commands via the VCOM component which might not be liked by the target...
    #
    ATTR{idProduct}=="0101", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0102", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0103", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0104", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0105", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0107", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0108", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    #
    # J-Link Product-Id assignment:
    # 0x1000 +
    # Bit 0: MSD
    # Bit 1: RNDIS
    # Bit 2: CDC
    # Bit 3: HID
    # Bit 4: J-Link (BULK via SEGGER host driver)
    # Bit 5: J-Link (BULK via WinUSB driver. Needs to be enabled in J-Link config area)
    #
    # [new format]
    # 0x1001: MSD
    # 0x1002: RNDIS
    # 0x1003: RNDIS  + MSD
    # 0x1004: CDC
    # 0x1005: CDC    + MSD
    # 0x1006: RNDIS  + CDC
    # 0x1007: RNDIS  + CDC    + MSD
    # 0x1008: HID
    # 0x1009: MSD    + HID
    # 0x100a: RNDIS  + HID
    # 0x100b: RNDIS  + MSD    + HID
    # 0x100c: CDC    + HID
    # 0x100d: CDC    + MSD    + HID
    # 0x100e: RNDIS  + CDC    + HID
    # 0x100f: RNDIS  + CDC    + MSD + HID
    # 0x1010: J_LINK_SEGGER_DRV
    # 0x1011: J_LINK_SEGGER_DRV                             + MSD
    # 0x1012: J_LINK_SEGGER_DRV                  + RNDIS
    # 0x1013: J_LINK_SEGGER_DRV                  + RNDIS    + MSD
    # 0x1014: J_LINK_SEGGER_DRV          + CDC              
    # 0x1015: J_LINK_SEGGER_DRV          + CDC              + MSD
    # 0x1016: J_LINK_SEGGER_DRV          + CDC   + RNDIS
    # 0x1017: J_LINK_SEGGER_DRV          + CDC   + RNDIS    + MSD
    # 0x1018: J_LINK_SEGGER_DRV + HID
    # 0x1019: J_LINK_SEGGER_DRV + HID                       + MSD
    # 0x101a: J_LINK_SEGGER_DRV + HID            + RNDIS
    # 0x101b: J_LINK_SEGGER_DRV + HID            + RNDIS    + MSD
    # 0x101c: J_LINK_SEGGER_DRV + HID    + CDC
    # 0x101d: J_LINK_SEGGER_DRV + HID    + CDC              + MSD
    # 0x101e: J_LINK_SEGGER_DRV + HID    + CDC   + RNDIS
    # 0x101f: J_LINK_SEGGER_DRV + HID    + CDC   + RNDIS    + MSD
    # 0x1020: J_LINK_WINUSB_DRV 
    # 0x1021: J_LINK_WINUSB_DRV                             + MSD
    # 0x1022: J_LINK_WINUSB_DRV                  + RNDIS
    # 0x1023: J_LINK_WINUSB_DRV                  + RNDIS    + MSD
    # 0x1024: J_LINK_WINUSB_DRV          + CDC              
    # 0x1025: J_LINK_WINUSB_DRV          + CDC              + MSD
    # 0x1026: J_LINK_WINUSB_DRV          + CDC   + RNDIS
    # 0x1027: J_LINK_WINUSB_DRV          + CDC   + RNDIS    + MSD
    # 0x1028: J_LINK_WINUSB_DRV + HID
    # 0x1029: J_LINK_WINUSB_DRV + HID                       + MSD
    # 0x102a: J_LINK_WINUSB_DRV + HID            + RNDIS
    # 0x102b: J_LINK_WINUSB_DRV + HID            + RNDIS    + MSD
    # 0x102c: J_LINK_WINUSB_DRV + HID    + CDC
    # 0x102d: J_LINK_WINUSB_DRV + HID    + CDC              + MSD
    # 0x102e: J_LINK_WINUSB_DRV + HID    + CDC   + RNDIS
    # 0x102f: J_LINK_WINUSB_DRV + HID    + CDC   + RNDIS    + MSD
    # 0x103x: J_LINK_SEGGER_DRV + J_LINK_WINUSB_DRV does not make any sense, therefore skipped
    # 0x1050: J_LINK_SEGGER_DRV          + 2x CDC
    # 0x1051: J_LINK_SEGGER_DRV          + 2x CDC              + MSD
    # 0x1052: J_LINK_SEGGER_DRV          + 2x CDC   + RNDIS
    # 0x1053: J_LINK_SEGGER_DRV          + 2x CDC   + RNDIS    + MSD
    # 0x1054: J_LINK_SEGGER_DRV          + 3x CDC
    # 0x1055: J_LINK_SEGGER_DRV          + 3x CDC              + MSD
    # 0x1056: J_LINK_SEGGER_DRV          + 3x CDC   + RNDIS
    # 0x1057: J_LINK_SEGGER_DRV          + 3x CDC   + RNDIS    + MSD
    # 0x1058: J_LINK_SEGGER_DRV + HID    + 2x CDC
    # 0x1059: J_LINK_SEGGER_DRV + HID    + 2x CDC              + MSD
    # 0x105a: J_LINK_SEGGER_DRV + HID    + 2x CDC   + RNDIS
    # 0x105b: J_LINK_SEGGER_DRV + HID    + 2x CDC   + RNDIS    + MSD
    # 0x105c: J_LINK_SEGGER_DRV + HID    + 3x CDC
    # 0x105d: J_LINK_SEGGER_DRV + HID    + 3x CDC              + MSD
    # 0x105e: J_LINK_SEGGER_DRV + HID    + 3x CDC   + RNDIS
    # 0x105f: J_LINK_SEGGER_DRV + HID    + 3x CDC   + RNDIS    + MSD
    # 0x1060: J_LINK_WINUSB_DRV          + 2x CDC
    # 0x1061: J_LINK_WINUSB_DRV          + 2x CDC              + MSD
    # 0x1062: J_LINK_WINUSB_DRV          + 2x CDC   + RNDIS
    # 0x1063: J_LINK_WINUSB_DRV          + 2x CDC   + RNDIS    + MSD
    # 0x1064: J_LINK_WINUSB_DRV          + 3x CDC
    # 0x1065: J_LINK_WINUSB_DRV          + 3x CDC              + MSD
    # 0x1066: J_LINK_WINUSB_DRV          + 3x CDC   + RNDIS
    # 0x1067: J_LINK_WINUSB_DRV          + 3x CDC   + RNDIS    + MSD
    # 0x1068: J_LINK_WINUSB_DRV + HID    + 2x CDC
    # 0x1069: J_LINK_WINUSB_DRV + HID    + 2x CDC              + MSD
    # 0x106a: J_LINK_WINUSB_DRV + HID    + 2x CDC   + RNDIS
    # 0x106b: J_LINK_WINUSB_DRV + HID    + 2x CDC   + RNDIS    + MSD
    # 0x106c: J_LINK_WINUSB_DRV + HID    + 3x CDC
    # 0x106d: J_LINK_WINUSB_DRV + HID    + 3x CDC              + MSD
    # 0x106e: J_LINK_WINUSB_DRV + HID    + 3x CDC   + RNDIS
    # 0x106f: J_LINK_WINUSB_DRV + HID    + 3x CDC   + RNDIS    + MSD
    #
    ATTR{idProduct}=="1001", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1002", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1003", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1004", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1005", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1006", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1007", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1008", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1009", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="100a", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="100b", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="100c", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="100d", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="100e", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="100f", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1010", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1011", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1012", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1013", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1014", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1015", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1016", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1017", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1018", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1019", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="101a", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="101b", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="101c", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="101d", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="101e", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="101f", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1020", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1021", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1022", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1023", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1024", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1025", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1026", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1027", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1028", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1029", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="102a", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="102b", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="102c", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="102d", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="102e", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="102f", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1050", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1051", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1052", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1053", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1054", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1055", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1056", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1057", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1058", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1059", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="105a", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="105b", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="105c", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="105d", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="105e", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="105f", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1060", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1061", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1062", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1063", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1064", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1065", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1066", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1067", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1068", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="1069", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="106a", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="106b", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="106c", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="106d", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="106e", ATTR{idVendor}=="1366", MODE="666"
    ATTR{idProduct}=="106f", ATTR{idVendor}=="1366", MODE="666"
    #
    # Handle known CMSIS-DAP probes (taken from mbed website and OpenOCD):
    #   VID 0x1366 (SEGGER)
    #     PID 0x1008-100f, 0x1018-101f, 0x1028-102f, 0x1058-105f, 0x1068-106f (SEGGER J-Link)
    #     We cover all of them via idProduct=10* and idVendor=1366
    #
    #   VID 0xC251 (Keil)
    #     PID 0xF001: (LPC-Link-II CMSIS_DAP)
    #     PID 0xF002: (OpenSDA CMSIS_DAP Freedom Board)
    #     PID 0x2722: (Keil ULINK2 CMSIS-DAP)
    #   VID 0x0D28 (mbed)
    #     PID 0x0204: MBED CMSIS-DAP
    #
    KERNEL=="hidraw*", ATTRS{idProduct}=="10*",  ATTRS{idVendor}=="1366", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="f001", ATTRS{idVendor}=="c251", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="f002", ATTRS{idVendor}=="c251", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="2722", ATTRS{idVendor}=="c251", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="0204", ATTRS{idVendor}=="c251", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="f001", ATTRS{idVendor}=="0d28", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="f002", ATTRS{idVendor}=="0d28", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="2722", ATTRS{idVendor}=="0d28", MODE="666"
    KERNEL=="hidraw*", ATTRS{idProduct}=="0204", ATTRS{idVendor}=="0d28", MODE="666"
    #
    # Make sure that J-Links are not captured by modem manager service
    # as this service would try detect J-Link as a modem and send AT commands via the VCOM component which might not be liked by the target...
    #
    ATTR{idProduct}=="1001", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1002", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1003", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1004", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1005", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1006", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1007", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1008", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1009", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="100a", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="100b", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="100c", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="100d", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="100e", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="100f", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1010", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1011", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1012", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1013", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1014", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1015", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1016", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1017", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1018", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1019", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="101a", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="101b", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="101c", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="101d", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="101e", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="101f", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1020", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1021", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1022", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1023", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1024", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1025", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1026", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1027", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1028", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1029", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="102a", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="102b", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="102c", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="102d", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="102e", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="102f", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1050", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1051", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1052", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1053", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1054", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1055", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1056", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1057", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1058", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1059", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="105a", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="105b", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="105c", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="105d", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="105e", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="105f", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1060", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1061", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1062", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1063", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1064", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1065", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1066", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1067", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1068", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="1069", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="106a", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="106b", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="106c", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="106d", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="106e", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="106f", ATTR{idVendor}=="1366", ENV{ID_MM_DEVICE_IGNORE}="1"
    #
    # Handle known CMSIS-DAP probes (taken from mbed website and OpenOCD):
    #   VID 0xC251 (Keil)
    #     PID 0xF001: (LPC-Link-II CMSIS_DAP)
    #     PID 0xF002: (OpenSDA CMSIS_DAP Freedom Board)
    #     PID 0x2722: (Keil ULINK2 CMSIS-DAP)
    #   VID 0x0D28 (mbed)
    #     PID 0x0204: MBED CMSIS-DAP
    #
    ATTR{idProduct}=="f001", ATTR{idVendor}=="c251", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="f002", ATTR{idVendor}=="c251", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="2722", ATTR{idVendor}=="c251", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0204", ATTR{idVendor}=="c251", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="f001", ATTR{idVendor}=="0d28", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="f002", ATTR{idVendor}=="0d28", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="2722", ATTR{idVendor}=="0d28", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTR{idProduct}=="0204", ATTR{idVendor}=="0d28", ENV{ID_MM_DEVICE_IGNORE}="1"
    #
    # Make sure that VCOM ports of J-Links can be opened with user rights
    # We simply say that all devices from SEGGER which are in the "tty" domain are enumerated with normal user == R/W
    #
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1366", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="c251", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0d28", MODE="0666", GROUP="dialout"
    #
    # End of list
    #
    LABEL="jlink_rules_end"
  '';
in

stdenv.mkDerivation (finalAttrs: {
  pname = "jlink-udev-rules";

  version = "1";
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -D ${rule} $out/lib/udev/rules.d/99-jlink.rules
    runHook postInstall
  '';
})
