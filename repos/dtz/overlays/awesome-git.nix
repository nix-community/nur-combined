self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-16";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "698fce9b4eaa03efb70a6092fe15b10a356d2dc0";
      sha256 = "18fyq3p9s9cmh6pjrd8hr7q34siimy2jwlazzwbh9srwdlyhz6nz";
    };
  });
}
