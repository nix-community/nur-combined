{ lib, stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "miniam";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/Wian1977/miniam/releases/download/v0.1.0/miniam-v0.1.0-linux-x86_64.tar.gz";
    sha256 = "d1f9540ed235852b88e78f9ae5ffc7b5d581806b586c94f3bae089f632917e33";
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
    description = "Apple Music in the terminal with true-color cover art and spectrum";
    homepage = "https://github.com/Wian1977/miniam";
    platforms = [ "x86_64-linux" ];
    mainProgram = "miniam";
  };
}
