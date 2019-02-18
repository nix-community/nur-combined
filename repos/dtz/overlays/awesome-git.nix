self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-17";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "052f6fb89dc56c241da42321f7ebb46373df5125";
      sha256 = "1pvd9ci9vqpiha01ddi1bmkn9lmc885dhdmyxzhzr0brqyd3xpwr";
    };
  });
}
