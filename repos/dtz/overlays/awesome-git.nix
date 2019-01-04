self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2019-01-03";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "6d2fc5c12b0980c77879ee5bf9b5f109f9e11365";
      sha256 = "16vs0fxhlwmkcw7fjcqsmlajxq51fm0n7jw1dxcylahviww03vf7";
    };
  });
}
