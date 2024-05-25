{ fetchurl
, stdenvNoCC
, makeWrapper
, unzip
, writeShellScript
, lib
, wine64
, wine
, lightspark ? null
, enableWine ? !stdenvNoCC.hostPlatform.isWindows
, enableLightspark ? false
, binArch ? if stdenvNoCC.hostPlatform.is64bit then "64bit" else "32bit"
}: let
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;
  mainProgram = "R3";
  wine' = if binArch == "64bit" then wine64 else wine;
in stdenvNoCC.mkDerivation rec {
  pname = "ffr-r3air-bin";
  version = "2.0.1";
  src = fetchurl {
    url = "https://github.com/flashflashrevolution/rCubed/releases/download/v${version}/rCubed-${version}-${binArch}.zip";
    sha256 = {
      "2.0.1-64bit" = "sha256-E6E0K2PVIRiOsJWfEBgR2Jl9hYc4wSN9Sobp2oorRZY=";
      "2.0.1-32bit" = "sha256-GP6pMbph5lAsX1uFZUNh4uGlDb3Jv2EtR05BHJbnQpc=";
    }."${version}-${binArch}";
  };

  nativeBuildInputs = [ unzip ]
    ++ optional (enableWine || enableLightspark) makeWrapper;
  buildInputs =
    optional enableWine wine'
    ++ optional enableLightspark lightspark;
  strictDeps = true;

  installDir = "lib/r3air";
  ${if enableWine then "wineBin" else null} = getExe wine';
  ${if enableLightspark then "lightsparkBin" else null} = getExe lightspark;
  inherit mainProgram;

  ${if enableWine then "setupScript" else null} = writeShellScript "${pname}-setup" ''
    set -eu
    mkdir -p "$FFR_R3_CACHE/"song_cache "$FFR_R3_DATA/"{dbinfo,replays,noteskins}
    ln -sf "$1/"* "$FFR_R3_DATA/"{dbinfo,replays,noteskins} "$FFR_R3_CACHE/"
  '';

  installPhase = let
    installExe = ''
      ln -s "$out/$installDir/R3.exe" $out/bin/$mainProgram.exe
    '';
    installWine = ''
      makeWrapper $wineBin $out/bin/$mainProgram \
        --run 'export FFR_R3_CACHE=''${FFR_R3_CACHE-$XDG_CACHE_HOME/r3air}' \
        --run 'export FFR_R3_DATA=''${FFR_R3_DATA-$XDG_DATA_HOME/r3air}' \
        --run "$setupScript $out/$installDir" \
        --run 'cd $FFR_R3_CACHE' \
        --append-flags "R3.exe"
    '';
    installLightspark = ''
      makeWrapper $lightsparkBin $out/bin/$mainProgram \
        --add-flags "--air" --add-flags "$out/$installDir/R3.exe"
    '';
  in ''
    runHook preInstall

    install -d "$out/$installDir" $out/bin
    mv 'Adobe AIR' META-INF \
      *.exe *.swf changelog.txt data mimetype \
      "$out/$installDir"

    ${if enableWine then installWine else if enableLightspark then installLightspark else installExe}

    runHook postInstall
  '';

  meta = {
    inherit mainProgram;
    homepage = "https://www.flashflashrevolution.com";
    license = lib.licenses.agpl3Plus;
  };
  passthru.ci = {
    skip = true;
  };
}
