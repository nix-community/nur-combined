{ stdenv, sources, unzip }:

stdenv.mkDerivation rec {
  pname = "maptourist";
  version = sources.maptourist.version;
  src = sources.maptourist;

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/share/gpxsee/maps
    ${unzip}/bin/unzip -j $src -d $out/share/gpxsee/maps
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
