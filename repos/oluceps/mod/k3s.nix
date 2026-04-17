{
  flake.modules.nixos.k3s =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.k3s;
    in
    {
      options.k3s = {
        role = lib.mkOption {
          type = lib.types.str;
        };
        clusterInit = lib.mkEnableOption "";
        extraFlags = lib.mkOption {
          type = with lib.types; (listOf str);
          default = [ ];
        };
        serverAddr = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };
      config = {
        vaultix.secrets.k3s_token = {
          owner = "root";
          mode = "400";
        };
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
              ]
              ++ (lib.optionals (cfg.role == "server") [
                "--disable-cloud-controller"
                "--advertise-address=${unique_addr_nomask}"
                "--cluster-cidr=fdcc:10::/56"
                "--service-cidr=fdcc:20::/108"
                "--cluster-dns=fdcc:20::a"

                "--etcd-arg=advertise-peer-urls=https://[${unique_addr_nomask}]:2380"
                "--etcd-arg=advertise-client-urls=https://[${unique_addr_nomask}]:2379"

                "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
                "--write-kubeconfig-mode 644"

                "--disable=servicelb"
                "--disable=traefik"
              ]);
            serverAddr = cfg.serverAddr;
          };
      };
    };
}
