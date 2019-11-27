self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-11-27";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "e411500ddaea4a81b7dfaf21371df10645fddea6";
      sha256 = "1vgazhjy2vbiha6qmzaj5zqxpvdgh9rz1n34rz7fzw766wpbjlg3";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
