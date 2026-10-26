{
  stdenv,
  fetchurl,
  lib,
}:
let
  version = "0.2.16";
  archMap = {
    "x86_64-linux" = {
      name = "x86_64";
      hash = "sha256-9KC+z3wGJTOS7JuTPnkDX5O3B8+/abnMzpyfSBOGFpw=";
    };
    "aarch64-linux" = {
      name = "aarch64";
      hash = "sha256-6kgO76YKPcc4EqcE/FqV5T4ZtTo+ginFsMi//dG2mI0=";
    };
  };
  currentArch =
    archMap.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  baseUrl = "https://github.com/akirco/pigma/releases/download/v${version}";
in
stdenv.mkDerivation {
  pname = "pigma";
  inherit version;
  src = fetchurl {
    url = "${baseUrl}/pigma-${currentArch.name}-unknown-linux-gnu.tar.gz";
    hash = currentArch.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";
  installPhase = "install -Dm755 pigma $out/bin/pigma";

  meta = with lib; {
    description = "A NetEase Cloud Music (网易云音乐) or local audio playback TUI client built with Ratatui";
    homepage = "https://github.com/akirco/pigma";
    changelog = "https://github.com/akirco/pigma/releases/tag/v${version}";
    license = licenses.asl20;
    # required by NUR: the output is not built from source
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "pigma";
    maintainers = [
      {
        name = "lorlike";
        github = "lorlike";
        githubId = 47685593;
      }
    ];
  };
}
