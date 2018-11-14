self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2018-11-12";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "bf50daf94e628c8a93ad961cde3a9416f8f3859d";
      sha256 = "07036qa769v9dnffvizyajwhyrw1mdc9zzfm6jcm65mgp7xmkpkz";
    };
  });
}
