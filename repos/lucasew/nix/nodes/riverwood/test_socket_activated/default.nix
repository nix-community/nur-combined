{ pkgs, lib, ... }:

{
  systemd = {
    sockets.wakeup-test = {
      socketConfig = {
        ListenStream = "/run/systemd-wakeup-test";
      };
      partOf = [ "wakeup-test.service" ];
      wantedBy = [ "sockets.target" "multi-user.target" ];
    };
    services.wakeup-test = {
      script = ''
        exec ${pkgs.python3.interpreter} ${./service.py}
      '';
      unitConfig = {
        After = [ "network.target" ];
      };
    };
  };
}
