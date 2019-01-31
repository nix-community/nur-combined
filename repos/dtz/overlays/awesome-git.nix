self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    #version = "4.3";
    name = "${pname}-${version}"; # override
    #name = "awesome-4.2-git-${version}";
    version = "2019-01-30";
    #nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "0b4a84ccf3cec4686fb0d475c5135537014469e8";
      #rev = "v${version}";
      sha256 = "1w4q79icvqgh04fcbq7vi46qqcxghvqipcikjlpdlk83bdnhrjvx";
    };
  });
}
