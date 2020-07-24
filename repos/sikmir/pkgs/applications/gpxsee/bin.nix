{ stdenv, fetchurl, undmg, sources }:
let
  pname = "gpxsee";
  version = "7.31";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "0gjpk89q5c1y9anmm26jv18i54dadn7q7r1djfsmsx77ibsbk8dm";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/GPXSee.app
    cp -R . $out/Applications/GPXSee.app
  '';

  meta = with stdenv.lib; {
    inherit (sources.gpxsee) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
