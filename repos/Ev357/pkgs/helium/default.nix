{
  lib,
  pkgs,
  _experimental-update-script-combinators,
  nix-update-script,
  ...
}: let
  version = "0.7.7.1";
  sourceMap = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
      hash = "sha256-qEHUFzCwsCyFNLFCC62wo2x1lr/boAI/UDsaaNP1vrc=";
    };
    aarch64-linux = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-arm64.AppImage";
      hash = "sha256-o4oSTWJtQFH8HCjv+bAEioKBqhSq7EC+f9KJKUFbBWg=";
    };
  };
in
  pkgs.appimageTools.wrapType2 rec {
    pname = "helium";
    inherit version;

    src =
      sourceMap.${pkgs.stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${pkgs.stdenv.hostPlatform.system}");

    passthru.updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {extraArgs = ["--system" "x86_64-linux"];})
      (nix-update-script {extraArgs = ["--system" "aarch64-linux" "--version" "skip"];})
    ];

    extraInstallCommands = let
      contents = pkgs.appimageTools.extractType2 {inherit pname version src;};
    in ''
      mkdir -p "$out/share/applications"
      mkdir -p "$out/share/lib/helium"
      cp -r ${contents}/opt/helium/locales "$out/share/lib/helium"
      cp -r ${contents}/usr/share/* "$out/share"
      cp "${contents}/${pname}.desktop" "$out/share/applications/"
      substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    '';

    meta = {
      description = "Private, fast, and honest web browser based on Chromium";
      homepage = "https://github.com/imputnet/helium-chromium";
      changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
      platforms = ["x86_64-linux" "aarch64-linux"];
      license = lib.licenses.gpl3;
      mainProgram = "helium";
    };
  }
