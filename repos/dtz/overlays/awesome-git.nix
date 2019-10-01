self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-10-01";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM"; # "dtzWill";
      repo = "awesome";
      rev = "85c8d5e205a9ab74bf3367ae494ed6858f74588c";
      sha256 = "1j6r683rzvr8491wy4rzri32f9al1a9xi2aq5ixzm98l901fpn3h";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
