self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2018-11-14";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "2308509f39e2d5a50ecab862f68b3728d1596711";
      sha256 = "0ls6gngx36sb9n31i0sm2qmgg62yxxagc4sd8xyzk9vbdmp9gir1";
    };
  });
}
