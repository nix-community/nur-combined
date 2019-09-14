self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-09-14";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM"; # "dtzWill";
      repo = "awesome";
      rev = "caf9a26660a721262e6fe34a1c746719d8806d4f";
      sha256 = "1a02b9avdsfsacscgnm45jx5qpvkp7zp62qc5rq5473a27y7fy4p";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
