self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    #version = "2019-04-28";
    version = "2019-08-29";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "237ac9a1648ac16f4a52a062311df6698c61d216";
      #rev = version;
      sha256 = "1gb0z5hhrisvdb8bipnkmpqqgxsnrib1j27njafpr6i5m7lq1da0";
    };
  });
}
