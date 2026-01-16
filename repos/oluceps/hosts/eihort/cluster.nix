{ ... }:
{
  repack.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    extraFlags = [
      "--node-label node-type=main"
    ];
  };
}
