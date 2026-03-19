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
      x86_64-linux = "1581l5kx5r0ha6x07nyczngxbjbsskczyjijrl7zzg8hi5hbjwg8";
      x86_64-darwin = "1fsigighcvhjwc1356j8n7bjn1w98gj1w6mphjk7kgk9pxkcj3fa";
      aarch64-linux = "1ijwjpa0a17m8ccrlqjk3z5fixqdld9gx62iprfq1xiq585k66dm";
      aarch64-darwin = "1wvk4c46awc3nmnl6yi4gxdb5dpnkaxsqhjik73gvrabvmhv6r8a";
      armv7l-linux = "0ygzjgvzfhknda695fi88w5sfby55ws1h2xqr033bwjhbgivraag";
      x86_64-linux = "1581l5kx5r0ha6x07nyczngxbjbsskczyjijrl7zzg8hi5hbjwg8";
      x86_64-darwin = "1fsigighcvhjwc1356j8n7bjn1w98gj1w6mphjk7kgk9pxkcj3fa";
      aarch64-linux = "1ijwjpa0a17m8ccrlqjk3z5fixqdld9gx62iprfq1xiq585k66dm";
      aarch64-darwin = "1wvk4c46awc3nmnl6yi4gxdb5dpnkaxsqhjik73gvrabvmhv6r8a";
      armv7l-linux = "0ygzjgvzfhknda695fi88w5sfby55ws1h2xqr033bwjhbgivraag";
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
