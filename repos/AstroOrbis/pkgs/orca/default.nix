{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  version = "1.4.197";

  sources = {
    x86_64-linux = {
      suffix = "";
      hash = "sha256-S8hGLRUf8BD6pUxka7FtzFR0v2ZO7V7FAoGC15kmQWs=";
    };
    aarch64-linux = {
      suffix = "-arm64";
      hash = "sha256-mmycw74/mIbvqNddFro0AaApzSYSNahrhM0cJDYTknE=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "orca: unsupported system ${stdenv.hostPlatform.system}");
in
pkgs.appimageTools.wrapType2 rec {
  pname = "orca";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux${source.suffix}.AppImage";
    inherit (source) hash;
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  extraInstallCommands =
    let
      contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in
    ''
      mkdir -p "$out/share/applications"
      cp -r ${contents}/usr/share/* "$out/share"
      cp "${contents}/orca-ide.desktop" "$out/share/applications/"

      wrapProgram $out/bin/${meta.mainProgram} \
        --add-flags "--ozone-platform-hint=auto"

      substituteInPlace "$out/share/applications/orca-ide.desktop" \
        --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    '';

  meta = {
    description = "Agent development environment for working with a fleet of parallel coding agents";
    homepage = "https://www.onorca.dev";
    downloadPage = "https://github.com/stablyai/orca/releases";
    license = lib.licenses.mit;
    mainProgram = "orca";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.attrNames sources;
  };
}
