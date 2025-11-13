{
  lib,
  stdenv,
  fetchfromgh,
  fetchFromGitea,
  fetchgdrive,
  unzip,
  wineWow64Packages,
  makeWrapper,
  withMaps ? false,
  withExtremum ? false,
}:
let
  maps = fetchFromGitea {
    domain = "parasite.kicks-ass.org:3000";
    owner = "sasgis";
    repo = "maps";
    rev = "578a182e0d8613107f67df0280b79419b43822f6";
    hash = "sha256-6j4KZlAKbBYoFr2ZBcfW0j2kmUTRbnzsaT1UNGXyKIo=";
    forceFetchGit = true;
  };
  extremum = fetchgdrive {
    id = "12PM_mEE8Xck036vXd5TAzPsUZeCnztJ5";
    hash = "sha256-6ZF4PsEFEGYt85umWJ/ToBW3JdeKEF4n6uU73hU8oLs=";
    name = "Extremum.zip";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sasplanet";
  version = "250505";

  src = fetchfromgh {
    owner = "sasgis";
    repo = "sas.planet.src";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-FEQf3SmgV/sszDJreU2+2iHEFRbFpQw3/pcelad4cKA=";
    name = "SAS.Planet.Release.${finalAttrs.version}.x64.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  # Post install regedit:
  # * increase font size: https://askubuntu.com/a/1313810
  # * dark theme: https://gist.github.com/Zeinok/ceaf6ff204792dde0ae31e0199d89398
  installPhase = ''
    mkdir -p $out/opt/sasplanet
    cp -r . $out/opt/sasplanet

    makeWrapper ${wineWow64Packages.stable}/bin/wine $out/bin/sasplanet \
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

  meta = {
    description = "SAS.Planet is a program designed for viewing and downloading high-resolution satellite imagery and conventional maps";
    homepage = "http://www.sasgis.org/sasplaneta/";
    changelog = "http://www.sasgis.org/mantis/changelog_page.php";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
