self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2019-01-17";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "370e6a9d4a5429939abce51e85eebc69a7a595f3";
      sha256 = "1vgh55qxa3dhfkclraw8z7mnwmdhdw7n8b9yby81ngzzqvr3bdq0";
    };

    makeFlags = (o.makeFlags or []) ++ [
      # not sure why we put things in share/tlp-pm vs default share/tlp
      # but follow along for now.
      "TLP_FLIB=${placeholder "out"}/share/tlp-pm/func.d"
    ];
  });
}
