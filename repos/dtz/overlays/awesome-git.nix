self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2020-02-15";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "6779a61b403bbc780608427d9e98569bb1139771";
      sha256 = "0igyqzzlrb71cmph459066ykf8njw7z8isi7j62fkxpy2qxsilqa";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
  awesome-gtk = self.awesome.override { gtk3Support = true; };
}
