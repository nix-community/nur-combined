self: super: {

  lilypond-unstable = super.stdenv.lib.overrideDerivation super.lilypond-unstable (p: rec {
    majorVersion = "2.19";
    minorVersion = "80";
    version = "${majorVersion}.${minorVersion}";
    name = "lilypond-${version}";
    src = super.fetchurl {
      url = "http://download.linuxaudio.org/lilypond/sources/v${majorVersion}/lilypond-${version}.tar.gz";
      sha256 = "0lql4q946gna2pl1g409mmmsvn2qvnq2z5cihrkfhk7plcqdny9n";
    };
  });

}
