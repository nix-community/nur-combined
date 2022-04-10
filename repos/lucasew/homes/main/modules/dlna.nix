{pkgs, ...}:
let
  inherit (pkgs) writeShellScript rclone;
  inherit (builtins) toString;
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
      dlna-local = {
        Unit = {
          Description = "DLNA service local";
        };
        Service = {
          Type = "exec";
          ExecStart = dlnaify {
            path = "/run/media/lucasew/Dados/DADOS/Lucas/Videos";
            name = "dlna local";
            extraFlags = "--addr :1234";
          };
          Restart = "onfailure";
        };
      };
      dlna-cloud = {
        Unit = {
          Description = "DLNA service cloud";
        };
        Service = {
          Type = "exec";
          ExecStart = dlnaify {
            path = "drive1:";
            name = "dlna cloud";
            extraFlags = "--addr :1235";
          };
          Restart = "onfailure";
        };
      };
    };
  };
}
