self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-18";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "ddf422dd0d3f9371a02ec95011e57ac69caca003";
      sha256 = "1dshldkyxxf7vnf11jgi4fzd0d238sg6qhp27j60wxflgbmny1qr";
    };
  });
}
