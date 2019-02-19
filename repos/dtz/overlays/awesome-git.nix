self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-18";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "24dbb1de202b2741f837a1ee249f3b0c99b92c40";
      sha256 = "0y66qdzldky3a2db2fvzvm7n6216kfsm3mskafhxc19h13idwphv";
    };
  });
}
