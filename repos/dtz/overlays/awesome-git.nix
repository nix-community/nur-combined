self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2020-01-11";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "e0bb29962d3d68613f4c9879e4a7f7ee5e65518b";
      sha256 = "1sk3rh0bbh4kpzhycq5lyybxmxw15bhlk52p9bs1fqvbbmkz45iw";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
