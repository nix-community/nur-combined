{ lib, stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "miniam";
  version = "0.1.2";

  src = fetchurl {
    url = "https://github.com/Wian1977/miniam/releases/download/v0.1.2/miniam-v0.1.2-linux-x86_64.tar.gz";
    sha256 = "04f9c388436148b1aa074a760e987e85464343e21d1d449ee9b7f9670d9fb8b3";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/doc/miniam
    install -m755 miniam $out/bin/miniam
    install -m644 README.md $out/share/doc/miniam/README.md
    runHook postInstall
  '';

  meta = with lib; {
    description = "Apple Music in the terminal with true-color cover art and a live spectrum";
    homepage = "https://github.com/Wian1977/miniam";
    platforms = [ "x86_64-linux" ];
    mainProgram = "miniam";
  };
}
