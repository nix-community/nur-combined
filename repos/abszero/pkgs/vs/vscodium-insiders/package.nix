{
  stdenv,
  lib,
  path,
  callPackage,
  fetchurl,
  commandLineArgs ? "",
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      x86_64-linux = "linux-x64";
      x86_64-darwin = "darwin-x64";
      aarch64-linux = "linux-arm64";
      aarch64-darwin = "darwin-arm64";
      armv7l-linux = "linux-armhf";
    }
    .${system} or throwSystem;

  archive_fmt = if stdenv.isDarwin then "zip" else "tar.gz";

  sha256 =
    {
      x86_64-linux = "1zcwg2kbijr6v74dda8nv1r8g8qhmr286gnnrl41pcpfjv6p46bg";
      x86_64-darwin = "095gb5hakcsfnck0z2rkgrdb27ll9pq28jkraypk6lz9iym8dasa";
      aarch64-linux = "07sq2lx79srka2c9qbsg16knln8asx4xj4mkbgqbkgm2mk0f0n5x";
      aarch64-darwin = "0qsivf3xqyfs09w6sj8p1p0p86gbsc0zacy55nfwd7qhbvdigz9k";
      armv7l-linux = "1ykp1xv55iy0qhfa0phrb1hjaw5vihfc6991ln9kmbx95jx1j0zb";
    }
    .${system} or throwSystem;

  sourceRoot = if stdenv.isDarwin then "" else ".";
in

callPackage "${path}/pkgs/applications/editors/vscode/generic.nix" rec {
  version = "1.100.03007-insider";
  pname = "vscodium-insiders";
  updateScript = ./update.sh;

  executableName = "codium-insiders";
  longName = "VSCodium - Insiders";
  shortName = "Codium - Insiders";
  inherit commandLineArgs;

  src = fetchurl {
    url =
      "https://github.com/VSCodium/vscodium-insiders/releases/download"
      + "/${version}/VSCodium-${plat}-${version}.${archive_fmt}";
    inherit sha256;
  };
  inherit sourceRoot;

  # tests = nixosTests.vscodium;

  meta = with lib; {
    description = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS (VS Code without MS branding/telemetry/licensing)
    '';
    longDescription = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS. It includes support for debugging, embedded Git
      control, syntax highlighting, intelligent code completion, snippets,
      and code refactoring. It is also customizable, so users can change the
      editor's theme, keyboard shortcuts, and preferences
    '';
    homepage = "https://github.com/VSCodium/vscodium-insiders";
    downloadPage = "https://github.com/VSCodium/vscodium-insiders/releases";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    # !!!: The insiders version breaks frequently, about once every month.
    #      You will get errors such as segfaults, crashes, issues related to
    #      read-only system, etc. For these reasons, I have personally switched
    #      to stable. Please use this package with caution.
    broken = true;
    mainProgram = "codium-insiders";
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
      "armv7l-linux"
    ];
  };
}
