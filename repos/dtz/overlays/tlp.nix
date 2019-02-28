self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-02-27";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "3fecbf343664fe2911b03b3785e5bc9ae463c27e";
      sha256 = "13nl62ajzbpqkgy0w8l99g3dqwwvzbbc3fw9ghzgzdj8jb5fy0gg";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
