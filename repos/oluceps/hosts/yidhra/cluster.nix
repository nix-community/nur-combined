{
  repack.k3s = {
    enable = false;
    role = "agent";
    serverAddr = "https://[fdcc::3]:6443";
    extraFlags = [
      "--node-label node-type=weak"
    ];
  };
}
