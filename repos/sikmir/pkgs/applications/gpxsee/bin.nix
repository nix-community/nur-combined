{ stdenv, fetchurl, undmg, sources }:
let
  pname = "gpxsee";
  version = "7.35";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    sha256 = "06v4gfbwawxrcv7p7v4lq2qdljv66qhy73qldjd6zx5rw1c73nrv";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/GPXSee.app
    cp -R . $out/Applications/GPXSee.app
  '';

  meta = with stdenv.lib; {
    inherit (sources.gpxsee) description homepage changelog;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
