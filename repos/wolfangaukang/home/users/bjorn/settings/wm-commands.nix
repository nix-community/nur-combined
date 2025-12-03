{
  pkgs,
  lib,
  config,
}:

let
  inherit (lib) getExe;
  inherit (pkgs)
    bluez
    brightnessctl
    ddcutil
    kitty
    libnotify
    pamixer
    rofi-bluetooth
    rofi-power-menu
    rofi-systemd
    rofiwl-custom
    swaybg
    swaylock
    waybar
    ;
  inherit (pkgs.sway-contrib) grimshot;

in
rec {
  bar = getExe waybar;
  bluetoothMgmt = getExe rofi-bluetooth;
  bluetoothToggle =
    let
      bluetoothctlPath = "${bluez}/bin/bluetoothctl";
    in
    pkgs.writeShellScriptBin "bt-toggle" ''
      STATE=`${bluetoothctlPath} show | grep Powered | awk '{print $2}'`
      if [[ $STATE == 'yes' ]]; then    
          ${bluetoothctlPath} power off    
          ${getExe libnotify} "Bluetooth" "Turned off"
      else
          ${bluetoothctlPath} power on
          ${getExe libnotify} "Bluetooth" "Turned on"
      fi
    '';
  brightness = getExe brightnessctl;
  calc = "${getExe rofiwl-custom} -show calc -modi calc -no-show-match -no-sort";
  kvm =
    let
      command = getExe ddcutil;
    in
    {
      peripherals = "${command} setvcp E7 0xFF00";
      screen = "${command} setvcp 60 0x1b";
    };
  lock = getExe swaylock;
  menu = "${getExe rofiwl-custom} -show combi -combi-modes 'window,drun' -modes combi";
  powerMenu = "${getExe rofiwl-custom} -show menu -modi \"menu:${getExe rofi-power-menu} --choices=shutdown/reboot/suspend/lockscreen/logout\"";
  screenshot =
    store: section:
    let
      baseCommand = "${getExe grimshot} --notify ${store} ${section}";
    in
    if store == "save" then
      "${baseCommand} \"${config.home.homeDirectory}/Bildujo/Screenshots/\$(date +'%F@%T').png\""
    else
      baseCommand;
  systemdMenu = getExe rofi-systemd;
  terminal = getExe kitty;
  top = "${getExe rofiwl-custom} -show top -modi top";
  volume = getExe pamixer;
  volumeMute = "${volume} --toggle-mute";
  wallpaper = "${getExe swaybg} -m fill -i ${config.home.homeDirectory}/.wallpaper.jpg";
}
