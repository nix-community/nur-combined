{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "gpxsee-bin";
  version = "9.0";

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "sha256-9QZdQPPg/Cl7fjM6ucGnno6HNQnkdEtAFnVTH66KSjI=";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "GPS log file viewer and analyzer";
    homepage = "https://www.gpxsee.org";
    changelog = "https://build.opensuse.org/package/view_file/home:tumic:GPXSee/gpxsee/gpxsee.changes";
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
