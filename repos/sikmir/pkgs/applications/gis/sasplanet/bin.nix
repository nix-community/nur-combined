{ lib, stdenv, fetchurl, unzip, wine, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "sasplanet-bin";
  version = "200606";

  src = fetchurl {
    url = "http://www.sasgis.org/programs/sasplanet/SASPlanet_${version}.zip";
    sha256 = "05pi0vr75y9yggya0bvf3bkyn3q3j9alriipy4lm9lsih4r7q09l";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/sasplanet
    cp -r . $out/opt/sasplanet

    makeWrapper ${wine}/bin/wine $out/bin/sasplanet \
      --run "[ -d \$HOME/.sasplanet ] || { cp -r $out/opt/sasplanet \$HOME/.sasplanet && chmod -R +w \$HOME/.sasplanet; }" \
      --add-flags "\$HOME/.sasplanet/SASPlanet.exe"
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "SAS.Planet is a program designed for viewing and downloading high-resolution satellite imagery and conventional maps";
    homepage = "http://www.sasgis.org/sasplaneta/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
