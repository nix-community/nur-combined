self: super: {
  nvme-cli = super.nvme-cli.overrideAttrs(o: rec {
    name = "nvme-cli-${version}";
    version = "2018-12-28";
    src = super.fetchFromGitHub {
      owner = "linux-nvme";
      repo = "nvme-cli";
      rev = "bc7b83eb45f9f915b63786e74619eca054dac948";
      sha256 = "1y7ap1aa2pba84rvj7ag9khwpa08mknfhqsbyvqxy0dgkfwhz8wf";
    };
  });
}
