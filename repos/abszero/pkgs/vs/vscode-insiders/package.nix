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
      x86_64-linux = "0v9q5gxhwb0ksdcql9fa1s6n58gz91kgzfi1smgcf1wr7j1xzwsm";
      x86_64-darwin = "0ich9f98lvzlpy5hl6yl8kvvdi5gd8jj7aiw7zv0c162n8mbbd8w";
      aarch64-linux = "1byp5zcl774mrfyfylpz675kbpd6vfqicff8krijyh78lm83ikyb";
      aarch64-darwin = "0a8y9vfmc38yd8wq7q8dnz9c43zii1rzkck4xbbnywhnxcxwpizd";
      armv7l-linux = "1i08cb5yqk8sv7jp5gkf7ak6xf35fliax9ff80lkpia96gr7rxd9";
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
