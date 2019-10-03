self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    #version = "2019-04-28";
    version = "2019-10-02";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "eca65630eca23f55e03dd67c165157b17fce470a";
      #rev = version;
      sha256 = "1mpnb2xzrm5r5dir271ciav917agq20mfy1bqzrr2p3mjvkip86s";
    };
  });
}
