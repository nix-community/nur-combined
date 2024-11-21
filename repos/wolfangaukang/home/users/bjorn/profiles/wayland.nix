{ pkgs
, lib
, config
, inputs
, localLib
, hostname
, ...
}:

let
  inherit (pkgs) nwg-look nordic pulsemixer rofi rofiwl-custom;
  inherit (localLib) getHostDefaults;
  commands = import "${inputs.self}/home/users/bjorn/settings/wm-commands.nix" { inherit pkgs config lib; };
  isWaylandWMEnabled = config.wayland.windowManager.sway.enable || config.wayland.windowManager.hyprland.enable;

in
{
  home = {
    packages = [
      # Modding
      nwg-look
      # https://sourcegraph.com/github.com/Misterio77/nix-config@9ad4c4f6792e10c4cb5076353250344398bdbfa7/-/blob/home/misterio/features/desktop/common/default.nix
      # GTK Theme
      nordic
      pulsemixer
    ];
    sessionVariables.QT_QPA_PLATFORM = "wayland";
  };
  gtk = {
    enable = true;
    font.name = "Fira Sans 8";
    gtk2.extraConfig = "gtk-application-prefer-dark-theme=1";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  programs = {
    rofi = {
      enable = true; # TODO: Move rofi enablement to workstation profile
      package = if isWaylandWMEnabled then rofiwl-custom else rofi;
      theme = "Arc-Dark"; # TODO: https://github.com/dctxmei/rofi-themes
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
      style = builtins.readFile "${inputs.dotfiles}/config/waybar/css/ragana.css";
      settings.mainBar = {
        output =
          let mainDisplay = (getHostDefaults hostname).display.id; in [ mainDisplay ];
        layer = "top";
        position = "bottom";
        height = 32;
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "clock" ];
        # https://sourcegraph.com/github.com/nix-community/home-manager@b787726a8413e11b074cde42704b4af32d95545c/-/blob/tests/modules/programs/waybar/settings-complex.nix?L9:14-9:20
        modules-right = [ "idle_inhibitor" "tray" "wireplumber" "network" "bluetooth" ];
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
        { event = "before-sleep"; command = "${commands.lock}"; }
        { event = "lock"; command = "${commands.lock}"; }
      ];
      timeouts = [
        { timeout = 300; command = "${commands.lock}"; }
        { timeout = 600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
      ];
    };
  };
}
