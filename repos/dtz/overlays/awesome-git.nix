self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2020-07-06";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "49a3859c8e5fa1679bd5c4e450c34fda2c17d2a5";
      sha256 = "0qnr2x01an51vn6jbg3x1giwb2243cjp08q7vkd0qh13kpgx9fpn";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
  awesome-gtk = self.awesome.override { gtk3Support = true; };
}
