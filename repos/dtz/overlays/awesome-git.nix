self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-24";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "f0490463323f9a115b5e0ff1e9cbbba61b5c51ea";
      sha256 = "108d2hs3klz99rgjw8ylwc5fnqqlby98hmvp93ihnad3nz2qbbmk";
    };
  });
}
