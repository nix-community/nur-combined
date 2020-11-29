{ stdenv, fetchurl, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "gpxsee-bin";
  version = "7.37";

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "0rq443dxmz5i0znhgy8x9x2jv45qv1r021630kw4w2bcilv3fz27";
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
