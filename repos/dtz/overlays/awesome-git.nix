self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-19";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "3cc364cef4fa8607d85cf02fdcf5eb782dc937dc";
      sha256 = "1f11qz2if44cgsayhnax75r5d7mcfc0wvb1p9ih2c3ch2sqd46rv";
    };
  });
}
