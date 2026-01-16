{
  repack.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://[fdcc::3]:6443";
    extraFlags = [
      "--node-label node-type=weak"
    ];
  };
}
# {
#   repack.k3s = {
#     enable = true;
#     role = "server";
#     serverAddr = "https://[fdcc::3]:6443";
#     extraFlags = [
#       "--node-taint CriticalAddonsOnly=true:NoExecute"
#       "--etcd-expose-metrics=true"
#     ];
#   };
# }
