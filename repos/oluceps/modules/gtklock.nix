{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types mkIf;

  cfg = config.programs.gtklock;
in
{
  options.programs.gtklock = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    wallpaper = mkOption {
      type = types.path;
      default = pkgs.fetchurl {
        url = "https://s3.nyaw.xyz/misskey//9cf87424-affa-46d6-acec-0cd35ff90663.jpg";
        sha256 = "0vrxr9imkp04skpbk6zmxjkcdlz029c9zc6xvsmab1hh2kzwkm33";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        # suspendCommand = "${pkgs.systemd}/bin/systemctl suspend";
        # lockCommand = "${pkgs.systemd}/bin/loginctl lock-session";
        gtklockCommand = "${pkgs.gtklock}/bin/gtklock -c ${gtklockConfig} -s ${gtklockStyle}";

        gtklockConfig = pkgs.writeText "gtklock-config.ini" (
          "[main]\nmodules="
          + "${pkgs.gtklock-playerctl-module}/lib/gtklock/playerctl-module.so"
          + ";"
          + "${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so"
          + "\n"
          + "[playerctl]\nposition=bottom-center"
        );

        gtklockStyle = pkgs.writeText "gtklock-style.css" ''
          #playerctl-revealer {
            padding-bottom: 100px
          }
          #powerbar-revealer {
            padding-bottom: 10px
          }
          window{background-image:url(${cfg.wallpaper});background-size:cover}
          #playerctl-revealer{padding-bottom:100px}
          #powerbar-revealer{padding-bottom:10px}
          #window-box{padding:64px;background-color:#20252d}
          #playerctl-box,#window-box{border:1px solid #000;border-radius:12px;box-shadow:0 4px 12px rgba(0,0,0,.5)}
          #playerctl-box{padding:10px;background-color:#353b4a}
        '';
      in
      [ (pkgs.writeShellScriptBin "start-gtklock" gtklockCommand) ];
  };
}
