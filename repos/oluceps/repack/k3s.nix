{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    optionals
    ;
  cfg = config.repack.k3s;
in
{
  options = {
    repack.k3s = {
      role = mkOption {
        type = lib.types.str;
      };
      clusterInit = mkEnableOption "";
      extraFlags = mkOption {
        type = with lib.types; (listOf str);
        default = [ ];
      };
      serverAddr = mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
      2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    networking.firewall.allowedUDPPorts = [
      8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];
    services.k3s =
      let
        inherit (lib.data.node.${config.networking.hostName}) unique_addr_nomask;
      in
      {
        enable = true;
        role = cfg.role;
        tokenFile = config.vaultix.secrets.k3s_token.path;
        clusterInit = cfg.clusterInit;
        extraFlags =
          cfg.extraFlags
          ++ [
            "--node-ip=${unique_addr_nomask}"
            "--write-kubeconfig /var/lib/k3s/k3s.yaml"
            "--config /var/lib/k3s/config.yaml"
          ]
          ++ (optionals (cfg.role == "server") [
            "--disable-cloud-controller"
            "--advertise-address=${unique_addr_nomask}"
            "--cluster-cidr=fdcc::/56"
            "--service-cidr=fdcc::/108"
            "--cluster-dns=fdcc::a"

            "--etcd-arg=advertise-peer-urls=https://[${unique_addr_nomask}]:2380"
            "--etcd-arg=advertise-client-urls=https://[${unique_addr_nomask}]:2379"

            "--etcd-arg=heartbeat-interval=120"
            "--etcd-arg=election-timeout=3000"
          ]);
        serverAddr = cfg.serverAddr;
      };
  };
}
