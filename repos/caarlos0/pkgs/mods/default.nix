{ system ? builtins.currentSystem, pkgs, fetchurl, installShellFiles }:
let
  shaMap = {
    x86_64-linux = "0yzzl33bp43wplhr52m0x8xyi7v3xmkjylhw192h7kg02zrx0pvw";
    aarch64-linux = "09swx3hw9ppk51b9s929nc4k9xli6fl8idwwiyvvbf8ycx3pjam5";
    x86_64-darwin = "1niwnbnki7m257bng3pd7g5p04pw0zis4mwwriimjfinsmk4lrqd";
    aarch64-darwin = "1g3vri0pg70c7z8di79nc33fnsi37l9kasdnyfw83zbz0v6dw7l6";
  };

  urlMap = {
    x86_64-linux =
      "https://github.com/charmbracelet/mods/releases/download/v0.1.1/mods_Linux_x86_64.tar.gz";
    aarch64-linux =
      "https://github.com/charmbracelet/mods/releases/download/v0.1.1/mods_Linux_arm64.tar.gz";
    x86_64-darwin =
      "https://github.com/charmbracelet/mods/releases/download/v0.1.1/mods_Darwin_x86_64.tar.gz";
    aarch64-darwin =
      "https://github.com/charmbracelet/mods/releases/download/v0.1.1/mods_Darwin_arm64.tar.gz";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "mods";
  version = "0.1.1";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./mods $out/bin/mods
  '';

  system = system;
}
