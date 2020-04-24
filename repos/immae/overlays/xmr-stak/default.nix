self: super: {
  xmr-stak = super.xmr-stak.overrideAttrs(old: rec {
    name = "xmr-stak-${version}";
    version = "1.0.4-rx";
    src = super.fetchFromGitHub {
      owner = "fireice-uk";
      repo = "xmr-stak";
      rev = version;
      sha256 = "1gsvm279i5jdcjhxsllnkyws6rq0n6qz4j9mg22fwvbgj5ms0gwp";
    };
    postPatch = "";
  });
}
