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
      x86_64-linux = "1w0v2i4r6yb1lszmm9h8m5w4lw2hyxm9d0x40vnl8ls76amgz447";
      x86_64-darwin = "05pqzp3a8y21ym0ic687x259s3xxjxyv0ii7v8iprbgsbhaczi87";
      aarch64-linux = "17kb48c711zdavm1dpbsc4sk7dn748qmfc663nk04hr81z2rfzap";
      aarch64-darwin = "0gp57ks6szqdzq3yfk1lddjgmkpfhmgh7b3yk31v1b5r0j79v92w";
      armv7l-linux = "14hwh5c32k5c1iirn82ivzm80ylya53qsjk9pvg3b4yzp6rwwkjx";
    }
    .${system} or throwSystem;
in

callPackage "${path}/pkgs/applications/editors/vscode/generic.nix" rec {
  version = "1.109.0-insider";
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
