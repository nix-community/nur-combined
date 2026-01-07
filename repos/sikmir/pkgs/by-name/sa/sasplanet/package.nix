{
  lib,
  stdenv,
  fetchfromgh,
  fetchgdrive,
  fetchgit,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  unzip,
  wineWow64Packages,
  makeWrapper,
  withMaps ? true,
  withExtremum ? false,
}:
let
  maps = fetchgit {
    url = "http://parasite.kicks-ass.org:3000/sasgis/maps.git";
    rev = "9b988fd8f39a5d0c44c2002d41735d2fe5a55b04";
    hash = "sha256-pxMlVM0w0+yZttSiCt96tLe9Lx/Lmea/txyQhy12AHM=";
  };
  extremum = fetchgdrive {
    id = "12PM_mEE8Xck036vXd5TAzPsUZeCnztJ5";
    hash = "sha256-6ZF4PsEFEGYt85umWJ/ToBW3JdeKEF4n6uU73hU8oLs=";
    name = "Extremum.zip";
  };
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/sasgis/sas.planet.src/8f8c9aedd9a641feec419a5609474d3a75cc24c9/Resources/MainIcon/icon64.png";
    hash = "sha256-KQR5fGrF6cLBDeIEVmU+YPQIdzFn43NrPLbTqGAKhp0=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sasplanet";
  version = "260101";

  src = fetchfromgh {
    owner = "sasgis";
    repo = "sas.planet.src";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-RGoVyb8agoIwoHFvswBTmqt2nDXMugjAqPaL9jbF4GY=";
    name = "SAS.Planet.Release.${finalAttrs.version}.x64.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    unzip
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "sasplanet";
      type = "Application";
      desktopName = "SAS.Planet";
      icon = "sasplanet";
      exec = "sasplanet";
      terminal = false;
      categories = [
        "Science"
        "Maps"
        "Geography"
      ];
    })
  ];

  # Post install regedit:
  # * increase font size: https://askubuntu.com/a/1313810
  # * dark theme: https://gist.github.com/Zeinok/ceaf6ff204792dde0ae31e0199d89398
  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/sasplanet
    cp -r . $out/opt/sasplanet
    install -Dm644 ${icon} $out/share/icons/hicolor/64x64/apps/sasplanet.png

    makeWrapper ${wineWow64Packages.stable}/bin/wine $out/bin/sasplanet \
      --run "[ -d \$HOME/.sasplanet ] || { cp -r $out/opt/sasplanet \$HOME/.sasplanet && chmod -R +w \$HOME/.sasplanet; }" \
      --add-flags "\$HOME/.sasplanet/SASPlanet.exe"

    ${lib.optionalString withMaps "cp -r ${maps}/* $out/opt/sasplanet/Maps/sas.maps"}
    ${lib.optionalString withExtremum "unzip ${extremum} -d $out/opt/sasplanet/Maps/sas.maps"}

    runHook postInstall
  '';

  preferLocalBuild = true;

  meta = {
    description = "SAS.Planet is a program designed for viewing and downloading high-resolution satellite imagery and conventional maps";
    homepage = "http://www.sasgis.org/sasplaneta/";
    changelog = "http://www.sasgis.org/mantis/changelog_page.php";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    mainProgram = "sasplanet";
    skip.ci = true;
  };
})
