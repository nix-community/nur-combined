self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2019-01-12";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "c20573e6ddf781f272795b0e594747e52cc1d631";
      sha256 = "1ys4wwcpyac7324ir8jllpwiqnn5bpwlj0bv89rgd1pfsf4499yh";
    };
  });
}
