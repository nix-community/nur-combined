{
  autoPatchelfHook,
  libpulseaudio,
  makeWrapper,
  stdenvNoCC,
  libXcursor,
  libXrandr,
  libdecor,
  fetchurl,
  alsa-lib,
  libXext,
  wayland,
  libX11,
  unzip,
  libGL,
  libXi,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "pokemon-fulldex";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  inherit (ver) version;

  meta = {
    description = "Launcher for Pokémon DS and GBA games in widescreen at 60 fps";
    homepage = "https://github.com/mamesj/pokemon-fulldex";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [Prinky];
    mainProgram = "pokemon-fulldex";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else
    stdenvNoCC.mkDerivation rec {
      inherit pname version src meta;

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
      ];

      buildInputs = [
        libpulseaudio
        libXcursor
        libXrandr
        alsa-lib
        libdecor
        libXext
        wayland
        libX11
        libGL
        libXi
      ];

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/${pname}
        cp -r pokemon-ds-wide/* $out/share/${pname}/

        mkdir -p $out/bin
        makeWrapper $out/share/${pname}/pokemon-ds-wide $out/bin/${pname} \
          --chdir $out/share/${pname} \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}:$out/share/${pname}"

        runHook postInstall
      '';
    }
