{config, pkgs, lib, ...}:
let
  masterIp = "192.168.69.1";
  masterAPIServerPort = 6443;
  api = "https://${masterIp}:${toString masterAPIServerPort}";
in {
  environment.variables.KUBECONFIG="/etc/kubernetes/cluster-admin.kubeconfig";
  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = masterIp;
    apiserverAddress = api;
    kubelet = {
      extraOpts = "--fail-swap-on=false";
      kubeconfig.server = api;
      hostname = config.networking.hostName;
    };
    apiserver = {
      securePort = masterAPIServerPort;
      advertiseAddress = masterIp;
    };
    addons.dns.enable = true;
    easyCerts = true;
  };
  environment.etc."cni/net.d".enable = false;
  environment.etc."cni/net.d/11-flannel.conf".source = "${config.environment.etc."cni/net.d".source}/11-flannel.conf";
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];
  services.nginx = {
    virtualHosts = {
      # future reference http://nginx.org/en/docs/http/server_names.html
      "*.${config.networking.hostName}.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://10.0.0.253";
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
      "kubernetes.${config.networking.hostName}.${config.networking.domain}" = {
        # rejectSSL = true;
        # forceSSL = true;
        locations."/" = {
          proxyPass = "https://localhost:6443";
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };
}
