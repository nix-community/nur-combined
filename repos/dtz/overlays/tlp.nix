self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-03-09";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "527b0e1acbf77dad13e973bd2a98412acadd5e7f";
      sha256 = "1rq6jzp7pxbm0nr1xy1zfp9f75vf1ysl43qs39ngc0b0yf8xxiyk";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
