self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-12-06";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "d2b7d292b014926069b2d67a5c40bc6edf254b98";
      sha256 = "1pwjjdiafi1p4zw845ra216sqy7x41zqwvf7hcb7mj3cdipz05j4";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
