self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-01-04";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "f89f39e981ebf94276288f4c4d9e30a0b630af49";
      sha256 = "0rxavpygqy1g66w4afj0407fay08s9pw54d2dggkh85ja4699gy7";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];

    # Fix typo
    postPatch = (o.postPatch or "") + ''
      substituteInPlace tlp-stat.in --replace echofi echo
    '';
  });
}
