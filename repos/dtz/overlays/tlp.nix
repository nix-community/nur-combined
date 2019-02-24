self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-02-22";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "499833bd6a0d419cd0925dacf9c79cb2a5b5e324";
      sha256 = "0yvdhw4zbncjhpq2d3n77wal1aygarp544anba9d60blldc5r48i";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
