{
  stdenv,
  lib,
  buildVscode,
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
      x86_64-linux = "1bs5fmd640f3fybh8vszppm0aq07rm617198r4vba75b3y9sl8zz";
      x86_64-darwin = "0k4by55v1gcxbq4qf5gbj4xg08xfs43843x7njis2q9mp6hbc275";
      aarch64-linux = "0cml7jamk5q6alp6qg5ar19d5i5pzhmzla5h33bcp3kkhhl92vg2";
      aarch64-darwin = "02b4h92mffipylp11r74qxrs3xil7jdkd5vy9vzlsfjaw1964zl6";
      armv7l-linux = "107jxppgf4x4v16pmzasyhzaijjlvxdjb3kybb4iddksnz9fd4gx";
      x86_64-linux = "1bs5fmd640f3fybh8vszppm0aq07rm617198r4vba75b3y9sl8zz";
      x86_64-darwin = "0k4by55v1gcxbq4qf5gbj4xg08xfs43843x7njis2q9mp6hbc275";
      aarch64-linux = "0cml7jamk5q6alp6qg5ar19d5i5pzhmzla5h33bcp3kkhhl92vg2";
      aarch64-darwin = "02b4h92mffipylp11r74qxrs3xil7jdkd5vy9vzlsfjaw1964zl6";
      armv7l-linux = "107jxppgf4x4v16pmzasyhzaijjlvxdjb3kybb4iddksnz9fd4gx";
    }
    .${system} or throwSystem;
in

buildVscode rec {
  version = "1.113.0-insider";
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

  tests = {};

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
