self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-12-03";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "7440cf66f041e26aee0ab8c5f33792f8669b91bd";
      sha256 = "0y9nn2jkf128mw7pdygdsb0j22c16wvz8fx6842r2qw6sakw7w89";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
