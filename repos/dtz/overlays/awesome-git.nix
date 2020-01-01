self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-12-28";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "b8c83fdf9c471c7bced75790dde0a23ba3e2b146";
      sha256 = "09gj4zvpnay0qcd8c6xf1ggx78iaylnnabk04s1b9jz273jmaipd";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
