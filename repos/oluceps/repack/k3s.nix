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

    environment.systemPackages = [ pkgs.etcd ];
    environment.etc."rancher/.keep".text = "";
    fileSystems."/etc/rancher" = {
      device = "/var/lib/k3s/etc/rancher";
      options = [ "bind" ];
    };
    environment.etc."cni/.keep".text = "";
    fileSystems."/etc/cni" = {
      device = "/var/lib/k3s/etc/cni";
      options = [ "bind" ];
    };
    networking.firewall.allowedTCPPorts = [
      6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
      2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    networking.firewall.allowedUDPPorts = [
      8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];
    virtualisation = {
      containerd = {
        enable = true;
        settings = {
          plugins."io.containerd.grpc.v1.cri".cni = {
            bin_dir = "/var/lib/rancher/k3s/data/cni";
            conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
          };
        };
      };
    };
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
            # "--write-kubeconfig /var/lib/k3s/k3s.yaml"
            # "--config /var/lib/k3s/config.yaml"
          ]
          ++ (optionals (cfg.role == "server") [
            "--disable-cloud-controller"
            "--advertise-address=${unique_addr_nomask}"
            "--cluster-cidr=fdcc:10::/56"
            "--service-cidr=fdcc:20::/108"
            "--cluster-dns=fdcc:20::a"

            "--etcd-arg=advertise-peer-urls=https://[${unique_addr_nomask}]:2380"
            "--etcd-arg=advertise-client-urls=https://[${unique_addr_nomask}]:2379"

            # "--etcd-arg=heartbeat-interval=500"
            # "--etcd-arg=election-timeout=5000"

            "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
            "--write-kubeconfig-mode 644"

            # "--flannel-backend=none" # WARNING: comment at 1st install. decomment after installing cillium.
            # "--disable-network-policy"
            # "--disable-kube-proxy"
            "--disable=servicelb"
            "--disable=traefik"
          ]);
        serverAddr = cfg.serverAddr;
      };
  };
}
