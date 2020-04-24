self: super: {
  bitlbee-discord = super.bitlbee-discord.overrideAttrs(old: rec {
    version = "master-3061edd";
    name = "bitlbee-discord-${version}";
    src = self.fetchFromGitHub {
      rev = "master";
      owner = "sm00th";
      repo = "bitlbee-discord";
      sha256 = "1d6nkr7wfrhra09ql258hvhr6q8kmnigcr14hjbwk10kqcb277y6";
    };
  });
}
