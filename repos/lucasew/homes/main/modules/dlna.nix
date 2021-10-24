{pkgs, ...}:
let
  inherit (pkgs) writeShellScript rclone;
  inherit (builtins) toString;
  systemdUserService = import ../../../lib/systemdUserService.nix;
  dlnaify = {path, name, extraFlags ? ""}: 
  let
    drv = writeShellScript "dlna" ''
      ${rclone}/bin/rclone serve dlna --read-only --name "${name}" "${toString path}" ${extraFlags}
    '';
  in "${drv}";
in
{
  config = {
    systemd.user.services = {
      dlna-local = systemdUserService {
        description = "DLNA service local";
        enable = false;
        command = dlnaify {
          path = "/run/media/lucasew/Dados/DADOS/Lucas/Videos";
          name = "dlna local";
          extraFlags = "--addr :1234";
        };
      };
      dlna-cloud = systemdUserService {
        description = "DLNA service cloud";
        enable = false;
        command = dlnaify {
          path = "drive1:";
          name = "dlna cloud";
          extraFlags = "--addr :1235";
        };
      };
    };
  };
}
