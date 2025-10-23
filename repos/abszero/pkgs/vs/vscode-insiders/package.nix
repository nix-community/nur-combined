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
      x86_64-linux = "190im4qaabxkhmjwqczl7x3c6lcfr17pn8xk7fash8sc9nhbfq7w";
      x86_64-darwin = "1sxikbw0pxfv5709gk06y5kx7yjcl8lr4vna2s8n63wfd1zd4w7s";
      aarch64-linux = "12y1cx1cjkb5ydpy8qj9mbfmmvplbgmfsbr2yd8ynaqpacgz2imv";
      aarch64-darwin = "0jhvhls7f1hdwj22wfcjjxsg6k93kg8b2bv57lc945dwg6cxn8ws";
      armv7l-linux = "1kxpc6lqp1v642gw19khy84a4sd1wsn7kmq0qpdw9vyb6pnkk5b3";
    }
    .${system} or throwSystem;
in

callPackage "${path}/pkgs/applications/editors/vscode/generic.nix" rec {
  version = "1.106.0-insider";
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
