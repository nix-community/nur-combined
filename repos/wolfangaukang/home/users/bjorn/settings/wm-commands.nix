{ pkgs
, lib
, config
}:

let
  inherit (lib) getExe;
  inherit (pkgs) bluez brightnessctl kitty libnotify pamixer swaybg swaylock waybar wofi;
  inherit (pkgs.sway-contrib) grimshot;

in
rec {
  brightness = getExe brightnessctl;
  terminal = getExe kitty;
  volume = getExe pamixer;
  volumeMute = "${volume} --toggle-mute";
  wallpaper = "${getExe swaybg} -m fill -i ${config.home.homeDirectory}/.wallpaper.jpg";
  screenshot = store: section:
    let
      baseCommand = "${getExe grimshot} --notify ${store} ${section}";
    in
      if store == "save" then "${baseCommand} \"${config.home.homeDirectory}/Bildujo/Screenshots/\$(date +'%F@%T').png\""
      else baseCommand;
  menu = "${getExe wofi} --show drun";
  lock = "${getExe swaylock} -f -e -l -s fill -i ${config.home.homeDirectory}/.lock.jpg";
  bluetoothToggle = let
    bluetoothctlPath = "${bluez}/bin/bluetoothctl";
    in pkgs.writeShellScriptBin "bt-toggle" ''
    STATE=`${bluetoothctlPath} show | grep Powered | awk '{print $2}'`
    if [[ $STATE == 'yes' ]]; then    
        ${bluetoothctlPath} power off    
        ${getExe libnotify} "Bluetooth" "Turned off"
    else
        ${bluetoothctlPath} power on
        ${getExe libnotify} "Bluetooth" "Turned on"
    fi
  '';
  bar = getExe waybar;
}
