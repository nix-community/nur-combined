{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  buildFHSEnv,
  writeShellScript,
  renderNode ? null,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  source = sources.${stdenv.hostPlatform.system};
in
buildFHSEnv (
  finalAttrs:
  let
    unwrapped = stdenvNoCC.mkDerivation {
      pname = "folia-major-bin-unwrapped";
      inherit (finalAttrs) version src;
      __structuredAttrs = true;
      strictDeps = true;

      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/share/folia-major"
        cp -a . "$out/share/folia-major/"
        runHook postInstall
      '';
    };
  in
  {
    pname = "folia-major-bin";
    inherit (source) version;
    src = fetchurl { inherit (source) url hash; };
    __structuredAttrs = true;
    strictDeps = true;

    executableName = "folia-major";
    targetPkgs =
      pkgs: with pkgs; [
        alsa-lib
        at-spi2-core
        cairo
        cups
        dbus
        expat
        glib
        gtk3
        libdrm
        libgbm
        libglvnd
        libpulseaudio
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        nspr
        nss
        pango
        stdenv.cc.cc.lib
        udev
        vulkan-loader
        wayland
        xdg-utils
      ];
    multiPkgs = _: [ ];
    runScript = writeShellScript "folia-major-launcher" ''
      ${lib.optionalString (renderNode != null) ''
        if [ -e ${lib.escapeShellArg renderNode} ]; then
          set -- ${lib.escapeShellArg "--render-node-override=${renderNode}"} "$@"
        fi
      ''}
      exec ${unwrapped}/share/folia-major/folia-major --ozone-platform=wayland "$@"
    '';

    extraInstallCommands = ''
      install -Dm644 ${unwrapped}/share/folia-major/resources/linux/folia-major.desktop \
        "$out/share/applications/folia-major.desktop"
      substituteInPlace "$out/share/applications/folia-major.desktop" \
        --replace-fail '__APP_PATH__' "$out/bin/folia-major" \
        --replace-fail '__ICON_PATH__' 'folia-major'
      install -Dm644 ${unwrapped}/share/folia-major/resources/icon.png \
        "$out/share/icons/hicolor/512x512/apps/folia-major.png"
    '';

    passthru = { inherit unwrapped; };
    meta = {
      description = "Music player with animated lyrics and audio visualization";
      homepage = "https://github.com/chthollyphile/folia-major";
      license = lib.licenses.agpl3Only;
      maintainers = [ lib.maintainers.xddxdd ];
      platforms = builtins.attrNames sources;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      mainProgram = "folia-major";
    };
  }
)
