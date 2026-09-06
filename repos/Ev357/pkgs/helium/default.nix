{
  lib,
  fetchurl,
  appimageTools,
  stdenv,
  _experimental-update-script-combinators,
  nix-update-script,
  widevine-cdm,
  enableWideVine ? false,
}: let
  repo = "https://github.com/imputnet/helium-linux";
in
  appimageTools.wrapAppImage rec {
    version = "0.16.5.1";
    pname = "helium";

    src = appimageTools.extract {
      pname = "helium";
      inherit version;
      src = let
        sourceMap = {
          x86_64-linux = fetchurl {
            url = "${repo}/releases/download/${version}/helium-${version}-x86_64.AppImage";
            hash = "sha256-N6+wwg46ufsbCqEJv/WpTWDCnI3tnFt58cG6TsGxXew=";
          };
          aarch64-linux = fetchurl {
            url = "${repo}/releases/download/${version}/helium-${version}-arm64.AppImage";
            hash = "sha256-zCZFBLbG/3pdeBx6qBrVWy4deNNtbu4EK9RTL9wgTQQ=";
          };
        };
      in
        sourceMap.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

      postExtract =
        lib.optionalString enableWideVine
        # bash
        ''
          mkdir -p $out/opt/helium/WidevineCdm
          cp -a ${widevine-cdm}/share/google/chrome/WidevineCdm/* $out/opt/helium/WidevineCdm/
        '';
    };

    passthru.updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        attrPath = "helium";
        extraArgs = ["--system" "x86_64-linux" "--flake" "--url" repo];
      })
      (nix-update-script {
        attrPath = "helium";
        extraArgs = ["--system" "aarch64-linux" "--version" "skip" "--flake" "--url" repo];
      })
    ];

    extraInstallCommands =
      # bash
      ''
        mkdir -p "$out/share/applications"
        mkdir -p "$out/share/lib/helium"
        cp -r ${src}/opt/helium/locales "$out/share/lib/helium"
        cp -r ${src}/usr/share/* "$out/share"
        cp "${src}/${pname}.desktop" "$out/share/applications/"
        substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=helium %U' 'Exec=${meta.mainProgram} %U'
      '';

    meta = {
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      description = "Private, fast, and honest web browser based on Chromium";
      homepage = "https://github.com/imputnet/helium-chromium";
      changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
      platforms = ["x86_64-linux" "aarch64-linux"];
      license =
        if enableWideVine
        then lib.licenses.unfree
        else lib.licenses.gpl3;
      mainProgram = "helium";
    };
  }
