{ stdenv, fetchurl, undmg, sources }:
let
  pname = "gpxsee";
  version = "7.33";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "175n5gabkzaq5bfwgwvizh65axpfz2x76s7w3x9fk51wdb424wph";
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
