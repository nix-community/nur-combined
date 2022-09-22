{config, pkgs, ...}:
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
}
