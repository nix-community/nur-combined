{ stdenv, fetchurl, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "gpxsee-bin";
  version = "8.0";

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "00b2spxbc05jsv87l5z6z0smjv58rm2mzrybkg9hk3yh58aa4ic0";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/GPXSee.app
    cp -r . $out/Applications/GPXSee.app
  '';

  meta = with stdenv.lib; {
    inherit (sources.gpxsee) description homepage changelog;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
