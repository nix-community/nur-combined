self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2019-01-05";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "ed7c243c03cba3d5c1fe1aa613af43c40da900d7";
      sha256 = "112llncw6yllp8x76aaibgcmbinbf3zdxdyz9xfj03hq9qf9v3w7";
    };
  });
}
