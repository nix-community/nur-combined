self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2018-12-17";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "820094c3c4306ce732553f0441b8a64703770206";
      sha256 = "1hsghm7vpx604c61144pshkyihifp5ih8s435xr2pjcb2vnm44a6";
    };
  });
}
