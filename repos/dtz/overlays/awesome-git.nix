self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2019-01-21";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "c1f00136998902319e98739d159631d6ace7d188";
      sha256 = "10b4hjs0lg7lw8376sh9ga2ykrjay5d3kmwlb8i7jzqjspnqwx5r";
    };
  });
}
