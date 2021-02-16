{ lib, stdenv, fetchurl, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "gpxsee-bin";
  version = "8.6";

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "1acfazwrl1c7d9pl5b6vvw5c04z10j4526ivf0lh7aliw9c8894s";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/GPXSee.app
    cp -r . $out/Applications/GPXSee.app
  '';

  meta = with lib; {
    inherit (sources.gpxsee) description homepage changelog;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
