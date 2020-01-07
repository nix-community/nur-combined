self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2020-01-06";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "6eef064da57efc7d6345329d27b59ccc4fd87148";
      sha256 = "1yj4h560mwdghm7rm684k7wz5rv35y5aqnjj75n0ij316aay9j9y";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
