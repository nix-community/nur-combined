self: super: {
  fwupd = super.fwupd.overrideAttrs(o: rec {
    name = "fwupd-${version}";
    version = "2018-11-05";

    src = super.fetchFromGitHub {
      owner = "hughsie";
      repo = "fwupd";
      rev = "412838360330402e9cfdb0b4ce90e810dd5f7e4e";
      sha256 = "02z3byrrpzjl0a16g0vcija1a9dwhl1vnfyzchxsizglxpvmw82s";
    };

  });
}
