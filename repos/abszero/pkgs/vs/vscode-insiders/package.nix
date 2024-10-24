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
      x86_64-linux = "1xai787gpdw3nc3rq80p3vl6ymz2cncpl7rrvyflifpz0hwqdz2q";
      x86_64-darwin = "0jkv0gpw47f353f11gzp56w5n3cmv339d7ixy5b54431a9d7srvn";
      aarch64-linux = "19maqvg2gj4m0rldp5l87r4hkvvr4rxvnf67j7m3njsnk7fiskyc";
      aarch64-darwin = "1z5842wz99z6jwsbcl3lrbd9gp8bdjnls80g4328iji8nh0p9kja";
      armv7l-linux = "0r7cmk6qa2xp521jnc9f30w8p8jnr6m07fydgs1x75sa53bwbxnm";
    }
    .${system} or throwSystem;
in

callPackage "${path}/pkgs/applications/editors/vscode/generic.nix" rec {
  version = "1.95.0-insider";
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
