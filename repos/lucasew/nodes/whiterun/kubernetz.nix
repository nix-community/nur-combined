{config, pkgs, ...}:
{
  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "localhost";
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];
}
