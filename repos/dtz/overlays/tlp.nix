self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    #version = "2019-04-28";
    version = "2019-08-18";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "81a99c0b531101c93f7953aedcf966bedca4e2de";
      #rev = version;
      sha256 = "1kq5hsqbbamwmscr6jinigxi655s3p22gwqdhcydrsd3nh4ddig5";
    };
  });
}
