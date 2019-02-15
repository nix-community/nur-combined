self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    #version = "4.3";
    name = "${pname}-${version}"; # override
    #name = "awesome-4.2-git-${version}";
    version = "2019-02-14";
    #nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "991d525f7ddb4e5918edc9e18691a71c596d3a1a";
      #rev = "v${version}";
      sha256 = "0cv4l5cx976zwy95p5p67f6mq6si5dnrl6m5py5fhmaq6n7sq07m";
    };

    patches = (o.patches or []) ++ [
      (super.fetchpatch { url = https://github.com/awesomeWM/awesome/pull/2653.patch; sha256 = "0agr40xn0cvjj5mw2cbkci0m7mpz1gbn21cmcx9s6684rd06rgg9"; })
    ];
  });
}
