{
  repack.k3s = {
    enable = true;
    role = "server";
    serverAddr = "https://[fdcc::3]:6443";
    extraFlags = [
      "--flannel-backend=none"
      "--disable-network-policy"
      "--disable-kube-proxy"
      "--disable=servicelb"
      "--disable=traefik"

      "--node-taint CriticalAddonsOnly=true:NoExecute"
      "--etcd-expose-metrics=true"
    ];
  };
}
