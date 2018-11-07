self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2018-11-03";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "b6b6bc0bd63ab73122f72d432c4d3dc896b54b80";
      sha256 = "0ziilfnpq09ka9i3g94rzrg4lz6s2i1940d61nkf3lkbvqm6247h";
    };
  });
}
