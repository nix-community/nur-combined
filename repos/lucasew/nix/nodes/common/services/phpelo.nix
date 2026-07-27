{
  config,
  lib,
  self,
  ...
}:

let
  cfg = config.services.phpelo;
  tsproxy-host  = "phpelo-${config.networking.hostName}";
  tsproxy-container = config.services.ts-proxy.hosts.${tsproxy-host}.unitName;
in

{
  imports = [
    "${self.inputs.phpelo}/nixos.nix"
  ];
  config = lib.mkIf cfg.enable {

    services.ts-proxy.hosts."${tsproxy-host}" = {
      enableTLS = true;
      enableFunnel = true;
      network = "unix";
      proxies = [ "phpelo.socket" ];
      address = cfg.socket;
    };

    virtualisation.oci-containers.containers."${tsproxy-container}" = {
      volumes = [
        "${cfg.socket}:${cfg.socket}"
      ];
    };
  };
}
