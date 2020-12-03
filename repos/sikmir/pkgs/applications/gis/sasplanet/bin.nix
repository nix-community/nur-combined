{ stdenv, unzip, wine, makeWrapper, sources }:
let
  year = stdenv.lib.substring 0 2 sources.sasplanet.version;
  month = stdenv.lib.substring 2 2 sources.sasplanet.version;
  day = stdenv.lib.substring 4 2 sources.sasplanet.version;
in
stdenv.mkDerivation {
  pname = "sasplanet-bin";
  version = "20${year}-${month}-${day}";

  src = sources.sasplanet;

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/sasplanet
    cp -r . $out/opt/sasplanet

    makeWrapper ${wine}/bin/wine $out/bin/sasplanet \
      --run "[ -d \$HOME/.sasplanet ] || { cp -r $out/opt/sasplanet \$HOME/.sasplanet && chmod -R +w \$HOME/.sasplanet; }" \
      --add-flags "\$HOME/.sasplanet/SASPlanet.exe"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    inherit (sources.sasplanet) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
