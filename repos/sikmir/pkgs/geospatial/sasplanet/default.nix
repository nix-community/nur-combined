{
  lib,
  stdenv,
  fetchurl,
  fetchgit,
  fetchgdrive,
  unzip,
  wine,
  makeWrapper,
  withMaps ? true,
  withExtremum ? false,
}:
let
  maps = fetchgit {
    url = "http://parasite.kicks-ass.org:3000/sasgis/maps.git";
    rev = "10221f2959ece3d430326adbc2daaf11c302f858";
    hash = "sha256-6j4KZlAKbBYoFr2ZBcfW0j8kmUTRbnzsaT1UNGXyKIo=";
  };
  extremum = fetchgdrive {
    id = "12PM_mEE8Xck036vXd5TAzPsUZeCnztJ5";
    hash = "sha256-6ZF4PsEFEGYt85umWJ/ToBW3JdeKEF4n6uU73hU8oLs=";
    name = "Extremum.zip";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sasplanet";
  version = "230909";

  src = fetchurl {
    url = "http://www.sasgis.org/programs/sasplanet/SASPlanet_${finalAttrs.version}.zip";
    hash = "sha256-tW82sjpiJqkbKpAI+5uvBfgI7Uqtii3Rn8ulnY3MxQM=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  # Post install regedit:
  # * increase font size: https://askubuntu.com/a/1313810
  # * dark theme: https://gist.github.com/Zeinok/ceaf6ff204792dde0ae31e0199d89398
  installPhase =
    ''
      mkdir -p $out/opt/sasplanet
      cp -r . $out/opt/sasplanet

      makeWrapper ${wine}/bin/wine $out/bin/sasplanet \
        --run "[ -d \$HOME/.sasplanet ] || { cp -r $out/opt/sasplanet \$HOME/.sasplanet && chmod -R +w \$HOME/.sasplanet; }" \
        --add-flags "\$HOME/.sasplanet/SASPlanet.exe"
    ''
    + lib.optionalString withMaps ''
      cp -r ${maps}/* $out/opt/sasplanet/Maps/sas.maps
    ''
    + lib.optionalString withExtremum ''
      unzip ${extremum} -d $out/opt/sasplanet/Maps/sas.maps
    '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "SAS.Planet is a program designed for viewing and downloading high-resolution satellite imagery and conventional maps";
    homepage = "http://www.sasgis.org/sasplaneta/";
    changelog = "http://www.sasgis.org/mantis/changelog_page.php";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
})
