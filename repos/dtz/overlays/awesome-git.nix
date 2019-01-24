self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2019-01-24";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "7f0e2e6bbf30bd6c5aba61bc4fbb06286c9f9d82";
      sha256 = "06g962dd4495q1nsd64rfgnp2rp7x2453x93b8dzdfgjgxqgpcva";
    };
  });
}
