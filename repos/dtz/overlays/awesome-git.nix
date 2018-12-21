self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2018-12-20";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "7d0976912e1c9fe5fe98ea0e5500c6faecfdf81f";
      sha256 = "1pqlviw83jpcpq49lfdhd3plbdsanil9kimhlk78mja07s2mvav8";
    };
  });
}
