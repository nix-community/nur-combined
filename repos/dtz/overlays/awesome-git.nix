self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-03-03";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "f7c20b38f10e50d4eb7cbd14ffe537a44c26f0d9";
      sha256 = "1d1rfv8m6dfp2qmj1w1grz67g209l8pbws53zhh4vrz742yn1sn0";
    };
  });
}
