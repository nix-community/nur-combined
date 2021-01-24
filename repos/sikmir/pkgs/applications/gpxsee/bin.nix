{ stdenv, fetchurl, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "gpxsee-bin";
  version = "8.3";

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "0b0w5d8fajxmk1jbkkxjzsfrpcby6vr1f3fnxnw0i8r7qvblw1xv";
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
