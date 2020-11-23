{ stdenv, unzip, wine, writers, sources }:
let
  year = stdenv.lib.substring 0 2 sources.sasplanet.version;
  month = stdenv.lib.substring 2 2 sources.sasplanet.version;
  day = stdenv.lib.substring 4 2 sources.sasplanet.version;

  runScript = writers.writeBash "sasplanet" ''
    ${wine}/bin/wine @out@/SAS.Planet.Release.${sources.sasplanet.version}/SASPlanet.exe
  '';
in
stdenv.mkDerivation {
  pname = "sasplanet";
  version = "20${year}-${month}-${day}";

  src = sources.sasplanet;

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/bin
    substitute ${runScript} $out/bin/sasplanet --subst-var out
    chmod +x $out/bin/sasplanet

    ${unzip}/bin/unzip $src -d $out
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    inherit (sources.sasplanet) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
