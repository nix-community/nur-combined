self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-12-13";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "9e3c418a03e10d1ab3f0517780f3dfc14be15362";
      sha256 = "0fs69ica7xf6r2cc5z2rhqz5gcjxpgqm99xd63sy8rr7v9sg4wfa";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
