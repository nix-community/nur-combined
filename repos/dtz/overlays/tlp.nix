self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-03-06";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "13780b5b6bb05b671eb74ad6ecd9703fc9502ba2";
      sha256 = "070l1lvp7xw4as3ixfmlic6qdzhymrgdgakyb6zn9bw42r2lx6zv";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
