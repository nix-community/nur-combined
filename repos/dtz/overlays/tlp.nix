self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-01-21";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "78440fa8d938db1c86ed745b36b392438c75b0db";
      sha256 = "0zrh49dfcds2r4b85znpcp4g4rgf3icbbjgslmngfjcj6n3s7h67";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
