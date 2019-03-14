self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-03-13";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "d8687dc251a62a5620fea577369ffda9bbb6c9b0";
      sha256 = "12s109mg8wmxyrc4qkc1k8ip758k5q32vd8cm6lg2n60q7h8n0l4";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];
  });
}
