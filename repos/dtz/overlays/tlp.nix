self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-03-05";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "a363d0326a21e198eb529f65dfb7c0b03faa1817";
      sha256 = "1bfwfdw113672r73dnanq2gixfk2q0sdk9shm5gb9xpqypkk1anr";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
