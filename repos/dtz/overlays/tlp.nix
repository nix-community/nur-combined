self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-01-07";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "a6047481ad9162018f94cee11241bb3d51abd855";
      sha256 = "0rpygg4c2hr17m8jgcbm90xc5w7did500416vaknd4ma6dwqqkhc";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
