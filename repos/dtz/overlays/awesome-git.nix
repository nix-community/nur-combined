self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    #version = "4.3";
    name = "${pname}-${version}"; # override
    #name = "awesome-4.2-git-${version}";
    version = "2019-02-01";
    #nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "a7474412daf2b0a84129e7c25af2a46ddecef826";
      #rev = "v${version}";
      sha256 = "1m7aw0xibj0lvhg0vmyg446a39lgszn8vrwnaqfanlbhrpmbgqdp";
    };
  });
}
