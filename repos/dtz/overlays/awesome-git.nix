self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-21";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "c4ff89a5fe1a8829d801c196ff45319a75d8a9b1";
      sha256 = "04i60xak8xn5xrws3y9107qxj6j0v16glc5b77rlj429jf2srcdh";
    };
  });
}
