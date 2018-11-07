self: super: {
  pdfpc = super.pdfpc.overrideAttrs(o: rec {
    name = "pdfpc-${version}";
    version = "2018-11-04";
    src = super.fetchFromGitHub {
      owner = "pdfpc";
      repo = "pdfpc";
      rev = "8a2816b7cbdd01b9558b799c212cdc38eb9a7f68";
      sha256 = "1awm6a7kblscaj61i2qfa4sr68zmzx1016valxljhlhs5bq6slnw";
    };
  });
}
