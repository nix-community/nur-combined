{ config, lib, pkgs, ... }:

let
  inherit (builtins) readFile toJSON;
  inherit (config) host;
  inherit (config.programs) niri;
  inherit (config.services.displayManager) dux-greeter;
  inherit (pkgs) fetchurl runCommand writeTextDir;
  inherit (import ../library/utilities.lib.nix { inherit lib; }) toKdl1String;

  duxGreeterNiriConfig = fetchurl {
    url = "https://raw.githubusercontent.com/duxlabs-dev/dux-greeter/refs/tags/v${dux-greeter.package.version}/core/internal/config/embedded/niri-greeter.kdl";
    hash = "sha256-e58l8w/IE2puAPdr81OZXjgG2Giqou/C8/IZyee9kF0=";
  };

  validate-niri-config = config: runCommand "validate-niri-config"
    { inherit config; nativeBuildInputs = [ niri.package ]; passAsFile = [ "config" ]; } ''
    niri validate --config "$configPath"
    touch "$out"
  '';
in
{
  # Pending NixOS 26.11
  disabledModules = [
    "programs/wayland/dms-shell.nix"
    "services/display-managers/dms-greeter.nix"
  ];
  imports = [
    <unstable/nixos/modules/programs/wayland/dux-shell.nix>
    <unstable/nixos/modules/services/display-managers/dux-greeter.nix>
  ];

  config = {
    # Core services
    hardware.bluetooth.enable = true;
    location.provider = "geoclue2";
    security.rtkit.enable = true;
    systemd.services.rtkit-daemon.serviceConfig.LogLevelMax = "notice";
    services.colord.enable = true;
    services.geoclue2.enable = true;
    services.gvfs.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    # Display manager
    fonts.packages = with pkgs; [ roboto ];
    services.displayManager.dux-greeter = {
      enable = true;
      compositor = {
        name = "niri";
        customConfig = readFile duxGreeterNiriConfig + ''
          output ${toKdl1String host.mainDisplay} { focus-at-startup; }
        '';
      };
      configFiles = [
        "${writeTextDir "session.json" (toJSON {
          wallpaperPath = host.dir + /assets/background.jpg;
        })}/session.json"
        "${writeTextDir "settings.json" (toJSON {
          clockFormat = "24h";
          currentThemeName = "monochrome";
          fontFamily = "Roboto";
          weatherEnabled = false;
        })}/settings.json"
      ];
    };
    systemd.services.greetd.enableStrictShellChecks = false; # TODO: Fix upstream
    system.checks = [ (validate-niri-config dux-greeter.compositor.customConfig) ]; # TODO: Upstream

    # Compositor
    programs.niri.enable = true;
    environment.systemPackages = with pkgs; [ xwayland-satellite ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Shell
    programs.dux-shell.enable = true;
  };
}
