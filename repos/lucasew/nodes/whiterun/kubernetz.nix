{config, pkgs, ...}:
{
  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "localhost";
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  environment.etc."cni/net.d".enable = false;
  environment.etc."cni/net.d/11-flannel.conf".source = "${config.environment.etc."cni/net.d".source}/11-flannel.conf";
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];
}
