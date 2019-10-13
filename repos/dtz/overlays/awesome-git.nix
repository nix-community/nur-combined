self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-10-12";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM"; # "dtzWill";
      repo = "awesome";
      rev = "bafe028a0579a804bb9d603fa3749e221b77446b";
      sha256 = "0sadrqma7z5g0szxbqrvjbwkhs0kqsivi6d4rlm8irmyyh57jniw";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
