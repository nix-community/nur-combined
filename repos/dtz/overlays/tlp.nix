self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    #version = "2019-03-09";
    version = "1.2";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      #rev = "527b0e1acbf77dad13e973bd2a98412acadd5e7f";
      rev = version;
      sha256 = "0vabhz3iil0danil0s88c6z97cycl03s2y948h8s9fmcgkh34gwd";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
