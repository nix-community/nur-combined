self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-27";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "e4e7abda5fb3b155cde8867b1c063ad4e8eb0d8b";
      sha256 = "178vxb3b6zpzxcff9w2h8bffidi9rly9sjhbl377q308mag3i7xr";
    };
  });
}
