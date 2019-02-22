self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-02-21";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "c12a92e0127811c864548ba2bffc5c907f4ae1fc";
      sha256 = "0asfrqrmj2sqsr176byhshylknfhcdqf57msyl1af3sfzvci3iwb";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
