self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-01-13";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "d8b4dda29cce72f979554781826fbab7c45c6e82";
      sha256 = "082l18qypca069cas1lpfv7nzahvi3dnmgls1pyviw3nzfggg44s";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
