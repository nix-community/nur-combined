{ lib, stdenv, fetchurl, fetchgit, fetchgdrive, unzip, wine, makeWrapper
, withMaps ? true
, withExtremum ? true
}:
let
  maps = fetchgit {
    url = "http://parasite.kicks-ass.org:3000/sasgis/maps.git";
    rev = "04de4be67481470e38f3af3b63caa2df511e26a8";
    sha256 = "1x1hcw2dicpi5394z3klwa3fj7cnjd91l05gyjkj0zxxd8246wx5";
  };
  extremum = fetchgdrive {
    id = "12PM_mEE8Xck036vXd5TAzPsUZeCnztJ5";
    sha256 = "1fx07haxwfz5x8kmw44aswjvf5d0sfgmi9lvycnnc405q4z7i4g9";
    name = "Extremum.zip";
  };
in
stdenv.mkDerivation rec {
  pname = "sasplanet-bin";
  version = "201212";

  src = fetchurl {
    url = "http://www.sasgis.org/programs/sasplanet/SASPlanet_${version}.zip";
    sha256 = "0a6xg75fj4ap0yc3z8sk0vf09dpj75jrkl7v97i2ycy6dim66wi0";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/sasplanet
    cp -r . $out/opt/sasplanet

    makeWrapper ${wine}/bin/wine $out/bin/sasplanet \
      --run "[ -d \$HOME/.sasplanet ] || { cp -r $out/opt/sasplanet \$HOME/.sasplanet && chmod -R +w \$HOME/.sasplanet; }" \
      --add-flags "\$HOME/.sasplanet/SASPlanet.exe"
  '' + lib.optionalString withMaps ''
    cp -r ${maps}/* $out/opt/sasplanet/Maps/sas.maps
  '' + lib.optionalString withExtremum ''
    unzip ${extremum} -d $out/opt/sasplanet/Maps/sas.maps
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "SAS.Planet is a program designed for viewing and downloading high-resolution satellite imagery and conventional maps";
    homepage = "http://www.sasgis.org/sasplaneta/";
    changelog = "http://www.sasgis.org/mantis/changelog_page.php";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
