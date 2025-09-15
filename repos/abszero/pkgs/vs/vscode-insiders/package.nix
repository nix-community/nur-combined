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
      x86_64-darwin = "darwin";
      aarch64-linux = "linux-arm64";
      aarch64-darwin = "darwin-arm64";
      armv7l-linux = "linux-armhf";
    }
    .${system} or throwSystem;

  archive_fmt = if stdenv.isDarwin then "zip" else "tar.gz";

  sha256 =
    {
      x86_64-linux = "1a841rlckirwsisdlpvc3n0qysy315hm1hfqx1mf08qkjzwhy9ni";
      x86_64-darwin = "1sga0ikhrwr997lc1mxklsdzfflx9dyqy5zp6x64xy45f1zngwi1";
      aarch64-linux = "1n6i04jw1p0bi6z0gahdwjrj2n48m1l0sawrz99gq3kiy0jaxg56";
      aarch64-darwin = "1ms88sg4sdwf1m840azwlp4zkl5wgcaykmxnwsmags9iv58njw6z";
      armv7l-linux = "1hrljrxcvs8vjawha7w6x40z5mndyhk9k83rmk4x4a6xiq8yy9l3";
    }
    .${system} or throwSystem;
in

callPackage "${path}/pkgs/applications/editors/vscode/generic.nix" rec {
  version = "1.105.0-insider";
  pname = "vscode-insiders";
  updateScript = ./update.sh;

  executableName = "code-insiders";
  longName = "Visual Studio Code - Insiders";
  shortName = "Code - Insiders";
  inherit commandLineArgs;

  src = fetchurl {
    name = "VSCode_${version}_${plat}.${archive_fmt}";
    url = "https://update.code.visualstudio.com/${version}/${plat}/insider";
    inherit sha256;
  };
  sourceRoot = "";

  meta = with lib; {
    description = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS
    '';
    longDescription = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS. It includes support for debugging, embedded Git
      control, syntax highlighting, intelligent code completion, snippets,
      and code refactoring. It is also customizable, so users can change the
      editor's theme, keyboard shortcuts, and preferences
    '';
    homepage = "https://code.visualstudio.com";
    downloadPage = "https://code.visualstudio.com/Updates";
    license = licenses.unfree;
    # !!!: The insiders version breaks frequently, about once every month.
    #      You will get errors such as segfaults, crashes, issues related to
    #      read-only system, etc. For these reasons, I have personally switched
    #      to stable. Please use this package with caution.
    broken = true;
    mainProgram = "code-insiders";
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "aarch64-linux"
      "armv7l-linux"
    ];
  };
}
