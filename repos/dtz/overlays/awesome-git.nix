self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2020-04-18";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "87e7b84ff54c050f86541421ec0aa93e325dd49d";
      sha256 = "0rqv0ys1dsv96brgvvlz2asirvp3xrfgbk2s6x2car3k658wsf66";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
  awesome-gtk = self.awesome.override { gtk3Support = true; };
}
