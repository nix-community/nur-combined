{ ... }:
{
  repack.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    extraFlags = [
      "--flannel-backend=none"
      "--disable-network-policy"
      "--disable-kube-proxy"
      "--disable=servicelb"
      "--disable=traefik"

      "--node-label node-type=main"
    ];
  };
}
