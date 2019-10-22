self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-10-18";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM"; # "dtzWill";
      repo = "awesome";
      rev = "0297bfff9ad88535fd9302fdb7d9b11459d6b1b4";
      sha256 = "1ss272n0k65chjg9m4yfyzljm60gga5p1dw97lqfw5i4kbsgi80r";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
