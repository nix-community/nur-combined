self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-09-23";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM"; # "dtzWill";
      repo = "awesome";
      rev = "aa7c7c80eee36828556a0b6fdb1e4f1536550e1c";
      sha256 = "1bfcgmxv43mnq57zc4wpslb6i9x9r2hi55182zslpr8vwalm9z48";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
