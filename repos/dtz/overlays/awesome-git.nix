self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-12-01";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "1b24acf2eaf681d9da96fe11a728e77f5aedd8a8";
      sha256 = "1x85l7v92aclp6lw8fp5g3la49zxnm9na6znr2rhfk2xs00wq966";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
