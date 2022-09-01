{ lib
, stdenv
, fetchurl
, fetchgit
, fetchgdrive
, unzip
, wine
, makeWrapper
, withMaps ? true
, withExtremum ? true
}:
let
  maps = fetchgit {
    url = "http://parasite.kicks-ass.org:3000/sasgis/maps.git";
    rev = "950e1b8a02ae7ac84a6ba55e93b57d63cd064688";
    hash = "sha256-Zz9//kVxqrNhDvgq3YNDRwRUd+mebFgVcXsSmEx1KzQ=";
  };
  extremum = fetchgdrive {
    id = "12PM_mEE8Xck036vXd5TAzPsUZeCnztJ5";
    hash = "sha256-6ZF4PsEFEGYt85umWJ/ToBW3JdeKEF4n6uU73hU8oLs=";
    name = "Extremum.zip";
  };
in
stdenv.mkDerivation rec {
  pname = "sasplanet-bin";
  version = "201212";

  src = fetchurl {
    url = "http://www.sasgis.org/programs/sasplanet/SASPlanet_${version}.zip";
    hash = "sha256-IHJjamzGMy/iSfvQmWU58rYE3AZToz+YB1cR6cp53Sg=";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  # Post install regedit:
  # * increase font size: https://askubuntu.com/a/1313810
  # * dark theme: https://gist.github.com/Zeinok/ceaf6ff204792dde0ae31e0199d89398
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
