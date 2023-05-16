{ ... }: {
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };
}
