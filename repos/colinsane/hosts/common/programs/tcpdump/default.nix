{ ... }: {
  sane.programs.tcpdump = {
    sandbox.net = "all";
    sandbox.autodetectCliPaths = "existingFileOrParent";
    sandbox.capabilities = [ "net_admin" "net_raw" ];
    sandbox.tryKeepUsers = true;
  };
}
