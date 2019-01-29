self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-01-25";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "241f1ee15d8b092b194b7663d8654c1e06818ed9";
      sha256 = "0r4pr1kdqhgzkcqjy8m60gnzz4dxjljwcsixdvg56w4khs48gi6d";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
