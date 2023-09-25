{ config, pkgs, lib, materusPkgs, inputs, ... }:
let
  optHip = pkgs.stdenv.mkDerivation rec {
  pname = "optHip";
  version = pkgs.hip.version;


  dontFixup = true;
  dontBuild = true;
  dontPatchELF = true;
  dontUnpack = true;
  sourceRoot = ".";

  buildInputs = [
    pkgs.hip
  ];

  installPhase = ''
    mkdir -p $out/opt/rocm
    ln -s ${pkgs.hip} $out/opt/rocm/hip
  '';
  };

  steamPkg = pkgs.steam.override {
    extraPkgs = pkgs: [
      config.materus.profile.packages.firefox
      optHip #for blender
      pkgs.steamcmd
      pkgs.nss_latest
      pkgs.libstrangle
      pkgs.libkrb5
      pkgs.keyutils
      pkgs.libGL
      pkgs.libglvnd
      pkgs.gamescope
      pkgs.steamPackages.steam
      pkgs.libxcrypt
      pkgs.gnutls
      pkgs.xorg.libXcursor
      pkgs.xorg.libXi
      pkgs.xorg.libXinerama
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.xinput
      pkgs.xorg.xcbutilwm
      pkgs.xorg.xcbutilimage
      pkgs.xorg.xcbutilkeysyms
      pkgs.xorg.xcbutilerrors
      pkgs.xorg.xcbutilrenderutil
      pkgs.xorg.xcbutil
      pkgs.xorg.xwininfo
      pkgs.yad
      pkgs.xdotool
      pkgs.libinput
      pkgs.openvdb
      pkgs.openssl
      pkgs.tbb_2021_8
      pkgs.gtk4
      pkgs.gtk3
      pkgs.glib
      pkgs.gsettings-desktop-schemas
      pkgs.fuse
      pkgs.libsForQt5.breeze-qt5
      pkgs.libsForQt5.breeze-gtk
      pkgs.libsForQt5.dolphin
      pkgs.samba4Full
      pkgs.tdb
      pkgs.jbig2enc
      pkgs.jbig2dec
      pkgs.vivaldi
      pkgs.steamtinkerlaunch

    ] ++ config.materus.profile.packages.list.fonts;

    extraLibraries = pkgs: [
      pkgs.libkrb5
      pkgs.keyutils
      pkgs.ncurses6
      pkgs.xorg.xinput
      pkgs.libinput
      pkgs.fontconfig
      pkgs.libxcrypt
      pkgs.gnutls
      pkgs.samba 
      pkgs.tdb
    ] ++
    (with config.hardware.opengl; if pkgs.hostPlatform.is64bit
    then [ package ] ++ extraPackages
    else [ package32 ] ++ extraPackages32);

    extraEnv = {
      XDG_DATA_DIRS = "/usr/share:\${XDG_DATA_DIRS}";
      OBS_VKCAPTURE = "1";
    };

  };

  cfg = config.materus.profile.steam;
in
{
  options.materus.profile.steam.enable = materusPkgs.lib.mkBoolOpt false "Enable materus steam settings for OS";
  options.materus.profile.steam.package = lib.mkOption {
    type = lib.types.package;
    default = steamPkg;
    description = "Package used by steam";
  };


  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = lib.mkDefault true;
    programs.steam = {
      enable = lib.mkDefault true;
      dedicatedServer.openFirewall = lib.mkDefault true;
      remotePlay.openFirewall = lib.mkDefault true;
    };
    environment.sessionVariables = rec {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = lib.mkDefault "\${HOME}/.steam/root/compatibilitytools.d";
    };
    environment.systemPackages = [
      steamPkg
      steamPkg.run

    ];
  };
}
