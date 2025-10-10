{
  nativeWayland ? false,
  appimageTools,
  makeWrapper,
  stdenvNoCC,
  fetchurl,
  fetchzip,
  lib,
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);

  pname = "osu-tachyon";
  inherit (info) version;

  platform = lib.getAttr stdenvNoCC.system info.platforms;

  fetcher =
    if platform.unpack
    then fetchzip
    else fetchurl;

  arguments =
    {
      inherit (platform) hash;
      url = "https://github.com/ppy/osu/releases/download/${info.version}/${platform.file}";
    }
    // (
      if platform.unpack
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
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    maintainers = with lib.maintainers; [
      gepbird
      stepbrobd
      Guanran928
      "Prinky"
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
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation {
      inherit pname version src meta passthru;

      installPhase = ''
        runHook preInstall
        APP_DIR="$out/Applications"
        mkdir -p "$APP_DIR"
        cp -r . "$APP_DIR"
        runHook postInstall
      '';
    }
  else
    appimageTools.wrapType2 {
      inherit pname version src meta passthru;

      extraPkgs = pkgs: with pkgs; [icu];

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
