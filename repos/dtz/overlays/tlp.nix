self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-01-06";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "460fa6cb1aa55705f9801412dd578390fc804560";
      sha256 = "0lp4jwqy760lvlp8ncpdsqb4g4a4zpb75flic39lysvrsqi6g2xl";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
