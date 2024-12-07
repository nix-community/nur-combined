{
  user,
  lib,
  pkgs,
  ...
}:
{
  programs.niri = {
    # aligh waybar rpc etc
    package = pkgs.niri;
    enable = true;
  };
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --remember --time --cmd ${pkgs.writeShellScript "wm-startup" ''
          niri-session
        ''}";
        inherit user;
      };
      default_session = initial_session;
    };
  };
  systemd.user = {
    services = {
      swaybg = {
        wantedBy = [ "niri.service" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart =
            let
              img = pkgs.fetchurl {
                url = "https://s3.nyaw.xyz/misskey//92772482-aef9-44e8-b1e2-1d49753a72fc.jpg";
                hash = "sha256-Y9TJ/xQQhqWq3t2wn1gS4NPGpuz1m7nu1ATcWWPKPW8=";
              };
            in
            "${lib.getExe pkgs.swaybg} -i ${img} -m fill";
          Restart = "on-failure";
        };
      };
      waybar = {
        wantedBy = [ "niri.service" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        # path = [ (lib.makeBinPath [ pkgs.niri ]) ];
        serviceConfig = {
          ExecStart = lib.getExe pkgs.waybar;
          Restart = "on-failure";
        };
      };
      # xwayland-satellite = {
      #   wantedBy = [ "niri.service" ];
      #   after = [ "graphical-session.target" ];
      #   wants = [ "graphical-session.target" ];
      #   serviceConfig = {
      #     ExecStart = lib.getExe pkgs.xwayland-satellite;
      #     Restart = "on-failure";
      #   };
      # };
    };
  };
}
