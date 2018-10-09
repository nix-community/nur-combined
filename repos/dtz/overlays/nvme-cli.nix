self: super: {
  nvme-cli = super.nvme-cli.overrideAttrs(o: rec {
    name = "nvme-cli-${version}";
    version = "2018-10-09";
    src = super.fetchFromGitHub {
      owner = "linux-nvme";
      repo = "nvme-cli";
      rev = "13651c4cf1e065897a5a16723ab77a8f4743b02f";
      sha256 = "0bhahm28nbjzsmss8hq0xmf5xwdfbykw1p1nk9jg0nb9mnkqx3fd";
    };
  });
}
