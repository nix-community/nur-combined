{
  nativeWayland ? false,
  appimageTools,
  makeWrapper,
  stdenvNoCC,
  fetchurl,
  fetchzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  platform = stdenvNoCC.hostPlatform.system;

  source = lib.helper.getPlatform platform ver;
  shouldUnpack = lib.helper.unpackPlatform platform ver;

  pname = "osu-tachyon";
  inherit (ver) version;

  fetcher =
    if shouldUnpack
    then fetchzip
    else fetchurl;

  arguments =
    source
    // (
      if shouldUnpack
      then {stripRoot = false;}
      else {}
    );

  src = fetcher arguments;

  meta = {
    description = "Rhythm is just a *click* away (AppImage version for score submission and multiplayer, and binary distribution for Darwin systems)";
    homepage = "https://osu.ppy.sh";
    license = with lib.licenses; [
      unfreeRedistributable
      cc-by-nc-40
      mit
    ];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    maintainers = with lib.maintainers; [
      gepbird
      stepbrobd
      Guanran928
      Prinky
    ];
    mainProgram = "osu!";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };

  passthru.updateScript = ./update.sh;
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation {
      inherit pname version src meta passthru;

      nativeBuildInputs = [makeWrapper];

      installPhase = ''
        runHook preInstall

        OSU_WRAPPER="$out/Applications/osu!.app/Contents"
        OSU_CONTENTS="osu!.app/Contents"

        mkdir -p "$OSU_WRAPPER/MacOS"

        cp -r "$OSU_CONTENTS/Info.plist" "$OSU_CONTENTS/Resources" "$OSU_WRAPPER"
        cp -r "osu!.app" "$OSU_WRAPPER/Resources/osu-wrapped.app"

        makeWrapper "$OSU_WRAPPER/Resources/osu-wrapped.app/Contents/MacOS/osu!" \
          "$OSU_WRAPPER/MacOS/osu!" --set OSU_EXTERNAL_UPDATE_PROVIDER 1

        runHook postInstall
      '';
    }
  else
    appimageTools.wrapType2 {
      inherit pname version src meta passthru;

      extraPkgs = pkgs: with pkgs; [icu];

      extraBwrapArgs = [
        "--ro-bind-try /etc/egl/egl_external_platform.d /etc/egl/egl_external_platform.d"
      ];

      extraInstallCommands = let
        contents = appimageTools.extract {inherit pname version src;};
      in ''
        . ${makeWrapper}/nix-support/setup-hook
        mv -v $out/bin/${pname} $out/bin/osu!

        wrapProgram $out/bin/osu! \
          ${lib.optionalString nativeWayland "--set SDL_VIDEODRIVER wayland"} \
          --set OSU_EXTERNAL_UPDATE_PROVIDER 1

        install -m 444 -D ${contents}/osu!.desktop -t $out/share/applications
        for i in 16 32 48 64 96 128 256 512 1024; do
          install -D ${contents}/osu.png $out/share/icons/hicolor/''${i}x$i/apps/osu.png
        done
      '';
    }
