{
  flake.modules.nixos.aria2 =
    { pkgs, ... }:
    {
      systemd.user.services.aria2 = {
        description = "aria2 Daemon";
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.aria2}/bin/aria2c";
          Restart = "on-failure";
        };
      };
    };
}
