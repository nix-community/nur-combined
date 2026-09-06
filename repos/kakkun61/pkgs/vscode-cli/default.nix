# Visual Studio Code CLI (standalone `code` binary for `code tunnel`,
# `code serve-web`, etc.). This is a different artifact from the desktop
# editor built by nixpkgs' vscode.nix + generic.nix: the download is a
# single statically-ish linked binary with no Electron UI, so it doesn't
# need generic.nix's app-bundle/FHS/desktop-item machinery. This file
# instead mirrors vscode.nix's per-platform fetchurl + hash table.

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      x86_64-linux = "cli-linux-x64";
      aarch64-linux = "cli-linux-arm64";
      armv7l-linux = "cli-linux-armhf";
      x86_64-darwin = "cli-darwin-x64";
      aarch64-darwin = "cli-darwin-arm64";
    }
    .${system} or throwSystem;

  hash =
    {
      x86_64-linux = "sha256-AlHUMORZ2B33hcJAglL4fGtJJ6Ff1sVRcWptQcnsL+M=";
      aarch64-linux = "sha256-SBW+jz9hLQRo9JKHL5oUb3CfxeXDib7rOWNkHdDPGp4=";
      armv7l-linux = "sha256-vW4ksqAAIcxOn5kauCX6mul2BuBonvqI5ywiqumCA/0=";
      x86_64-darwin = "sha256-JIp5AnkjHRm8/pokPuyT44hVDKGM1KBADu9i6tinIko=";
      aarch64-darwin = "sha256-4PM7539RFTDroMCTpgbzYEUkuOuLyZqwLMD50CpdfxA=";
    }
    .${system} or throwSystem;

  version = "1.136.1";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vscode-cli";
  inherit version;

  src = fetchurl {
    name = "vscode-cli-${finalAttrs.version}-${plat}.tar.gz";
    url = "https://update.code.visualstudio.com/${finalAttrs.version}/${plat}/stable";
    inherit hash;
  };

  # the archive contains a single `code` executable with no wrapping directory
  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 code $out/bin/code
    runHook postInstall
  '';

  meta = {
    description = "Command-line interface for Visual Studio Code (tunnels, remote CLI, serve-web)";
    homepage = "https://code.visualstudio.com/docs/editor/command-line";
    downloadPage = "https://code.visualstudio.com/Updates";
    license = lib.licenses.unfree;
    mainProgram = "code";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "armv7l-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
