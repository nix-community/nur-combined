self: super: {
  fwupd = super.fwupd.overrideAttrs(o: rec {
    name = "fwupd-${version}";
    version = "2018-10-10";

    src = super.fetchFromGitHub {
      owner = "hughsie";
      repo = "fwupd";
      rev = "78599edcc9194a68f1d412ff65875a98a7832011";
      sha256 = "1pi06gbqp4p6za3s8vmcy24hf7p4inzc34d5q4bf2bk7gf23kw5y";
    };
  });
}
