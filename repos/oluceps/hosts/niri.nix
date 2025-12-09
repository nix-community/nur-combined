{
  user,
  lib,
  pkgs,
  inputs',
  ...
}:
{
  imports = [ ./noctalia.nix ];
  programs.niri = {
    # aligh waybar rpc etc
    package = pkgs.niri;
    enable = true;
  };
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${lib.getExe pkgs.tuigreet} --remember --time --cmd ${lib.getExe' pkgs.niri "niri-session"}";
        inherit user;
      };
      default_session = initial_session;
    };
  };
  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };
  services.gnome.gcr-ssh-agent.enable = true;
  environment.systemPackages = [
    pkgs.show-current-ws
  ];

  systemd.user = {
    services = {

      niri-flake-polkit = {
        description = "PolicyKit Authentication Agent provided by niri-flake";
        wantedBy = [ "niri.service" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      }; # swaybg = {
      #   wantedBy = [ "niri.service" ];
      #   wants = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   serviceConfig = {
      #     ExecStart =
      #       let
      #         img = pkgs.fetchurl {
      #           url = "https://s3.nyaw.xyz/misskey//92772482-aef9-44e8-b1e2-1d49753a72fc.jpg";
      #           hash = "sha256-Y9TJ/xQQhqWq3t2wn1gS4NPGpuz1m7nu1ATcWWPKPW8=";
      #         };
      #       in
      #       "${lib.getExe pkgs.swaybg} -i ${img} -m fill";
      #     Restart = "on-failure";
      #   };
      # };
      # waybar = {
      #   wantedBy = [ "niri.service" ];
      #   wants = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   # path = [ (lib.makeBinPath [ pkgs.niri ]) ];
      #   serviceConfig = {
      #     ExecStart = lib.getExe pkgs.waybar;
      #     Restart = "on-failure";
      #   };
      # };
      vicinae-server = {
        wantedBy = [ "niri.service" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        requires = [ "dbus.socket" ];
        path = [ (lib.makeBinPath [ pkgs.niri ]) ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.vicinae} server";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          Environment = [
            "USE_LAYER_SHELL=1"
            "PATH=/run/wrappers/bin:/home/${user}/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:/home/${user}/.nix-profile/bin:/nix/profile/bin:/home/${user}/.local/state/nix/profile/bin:/etc/profiles/per-user/${user}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
          ];
          Restart = "always";
          RestartSec = 5;
          KillMode = "process";
        };
      };
    };
  };
}
