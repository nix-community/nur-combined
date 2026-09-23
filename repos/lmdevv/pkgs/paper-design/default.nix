{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  undmg,
}:

let
  inherit (stdenv) hostPlatform;
  pname = "paper-design";
  version = "0.5.12";

  sources = {
    x86_64-linux = fetchurl {
      name = "paper-desktop-0.5.12-x86_64.AppImage";
      url = "https://download.todesktop.com/2601167vjw8xe/paper-desktop-0.5.12-build-260923mbui5shcl-x86_64.AppImage";
      hash = "sha256-st9hMDQt6OMAzFPncTfqvu9rsS+Q689z5OX3rxaubzU=";
    };
    aarch64-darwin = fetchurl {
      name = "paper-desktop-0.5.12-aarch64.dmg";
      url = "https://download.todesktop.com/2601167vjw8xe/Paper%200.5.12%20-%20Build%20260923mbui5shcl-arm64.dmg";
      hash = "sha256-AZY8Se/Wvxteb3Uu23fF/E/vxvrjeqe+ZRjFj5t15P0=";
    };
  };

  source =
    sources.${hostPlatform.system} or (throw "paper-design: unsupported system ${hostPlatform.system}");

  linux = appimageTools.wrapType2 {
    inherit pname version;
    src = source;

    extraInstallCommands =
      let
        contents = appimageTools.extract {
          inherit pname version;
          src = source;
        };
      in
      ''
        install -Dm444 ${contents}/paper-desktop.desktop \
          $out/share/applications/paper-design.desktop
        substituteInPlace $out/share/applications/paper-design.desktop \
          --replace-fail 'Exec=AppRun --no-sandbox %U' \
                         'Exec=paper-design --no-sandbox %U'

        mkdir -p $out/share/icons
        cp -R ${contents}/usr/share/icons/hicolor $out/share/icons/
      '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version;
    src = source;

    nativeBuildInputs = [ undmg ];
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"
      app_bundle="$(echo *.app)"
      cp -R "$app_bundle" "$out/Applications/"
      ln -s "$out/Applications/$app_bundle/Contents/MacOS/Paper" \
        "$out/bin/paper-design"

      runHook postInstall
    '';

    # Editing the app bundle would invalidate its upstream signature.
    dontFixup = true;
  };
in
(if hostPlatform.isDarwin then darwin else linux).overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // {
    inherit sources;
    updateScript = ../../scripts/update-paper-design.sh;
  };

  meta = with lib; {
    description = "Connected canvas for designing interfaces with people and AI agents";
    homepage = "https://paper.design";
    downloadPage = "https://paper.design/downloads";
    changelog = "https://paper.design/changelog";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = [ "lmdevv" ];
    platforms = builtins.attrNames sources;
    mainProgram = "paper-design";
  };
})
