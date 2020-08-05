{ stdenvNoCC, lib, sources, unzip }:

stdenvNoCC.mkDerivation {
  pname = "maptourist";
  version = sources.maptourist.version;
  src = sources.maptourist;

  dontUnpack = true;

  installPhase = "${unzip}/bin/unzip $src -d $out";

  preferLocalBuild = true;

  meta = with lib; {
    inherit (sources.maptourist) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
