self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-02-15";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "57c5777a2a9b0c330ce4361fb9d533e4a9305d1f";
      sha256 = "05aix2fax1vpgh1awmz2wvq53bwcnwncgbdwqvxg2qjclcfq3flf";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
