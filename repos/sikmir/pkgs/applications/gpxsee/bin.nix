{ stdenv, fetchurl, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "gpxsee-bin";
  version = "8.2";

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "0g1ph7dyig5phvnq22g8j2xrp6gnmxlndrncglgc7fij4msxnrwf";
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
