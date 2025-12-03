{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  inherit (inputs) dotfiles self;
  commands = import "${self}/home/users/bjorn/settings/wm-commands.nix" { inherit pkgs config lib; };
  isWaylandWMEnabled =
    config.wayland.windowManager.sway.enable || config.wayland.windowManager.hyprland.enable;

in
{
  home.packages = with pkgs; [
    # Modding
    nwg-look
    pulsemixer
  ];
  gtk =
    let
      package = pkgs.nordic;
      name = "Nordic-darker";
    in
    {
      enable = true;
      colorScheme = "dark";
      font = {
        name = "Fira Sans";
        package = pkgs.fira;
        size = 10;
      };
      theme = { inherit package name; };
      cursorTheme = {
        inherit package;
        name = "Nordic-cursors";
      };
      iconTheme = { inherit package name; };
    };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  programs = {
    rofi =
      let
        inherit (pkgs) rofi rofiwl-custom;
      in
      {
        enable = true;
        package = if isWaylandWMEnabled then rofiwl-custom else rofi;
        theme = "Ragana";
      };
    swaylock = {
      enable = isWaylandWMEnabled;
      settings = {
        daemonize = true;
        ignore-empty-password = true;
        indicator-caps-lock = true;
        scaling = "fill";
        image = "${config.home.homeDirectory}/.lock.jpg";
      };
    };
    waybar = {
      enable = isWaylandWMEnabled;
      style = builtins.readFile "${dotfiles}/config/waybar/css/ragana.css";
      settings.mainBar = {
        layer = "top";
        position = "bottom";
        height = 32;
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "clock" ];
        # https://sourcegraph.com/github.com/nix-community/home-manager@b787726a8413e11b074cde42704b4af32d95545c/-/blob/tests/modules/programs/waybar/settings-complex.nix?L9:14-9:20
        modules-right = [
          "idle_inhibitor"
          "tray"
          "wireplumber"
          "network"
          "bluetooth"
        ];
        # Modules
        clock = {
          interval = 30;
          format = "{:%a %d %b %Y %H:%M}";
          calendar = {
            mode = "month";
            weeks-pos = "left";
            on-scroll = "1";
          };
        };
        idle_inhibitor = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
        };
        wireplumber = {
          "format" = "  {volume}%";
          "format-muted" = "";
          "on-click" = "${commands.volumeMute}";
        };
        bluetooth = {
          "format" = "   {status} ";
          "format-disabled" = "";
          "format-connected" = "   {device_alias} ";
          "format-connected-battery" = "   {device_alias} {device_battery_percentage}% ";
          "on-click" = "${lib.getExe commands.bluetoothToggle}";
        };
        network = {
          "format-wifi" = "  {essid} ({signalStrength}%)";
          "format-ethernet" = "  {ifname}";
          "format-disconnected" = "";
        };
      };
    };
  };
  services = {
    fnott.enable = isWaylandWMEnabled; # TODO: Customize Fnott
    # TODO: Kanshi https://sourcegraph.com/github.com/nix-community/home-manager@a561ad6ab38578c812cc9af3b04f2cc60ebf48c9/-/blob/tests/modules/services/kanshi/basic-configuration.nix?L3:14-3:20
    kanshi.enable = isWaylandWMEnabled;
    swayidle = {
      enable = isWaylandWMEnabled;
      events = [
        {
          event = "before-sleep";
          command = "${commands.lock}";
        }
        {
          event = "lock";
          command = "${commands.lock}";
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = "${commands.lock}";
        }
      ];
    };
  };
  xdg.configFile."rofi/themes/Ragana.rasi".source = "${dotfiles}/config/rofi/themes/Ragana.rasi";
}
