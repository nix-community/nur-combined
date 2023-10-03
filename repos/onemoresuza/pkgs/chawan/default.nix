{
  curl,
  fetchFromSourcehut,
  lib,
  nim2,
  pkg-config,
  stdenv,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "chawan";
  version = "unstable-2023-10-02";
  src = fetchFromSourcehut {
    owner = "~bptato";
    repo = pname;
    rev = "3235507b98f178f58657a86370e57e0a8b130684";
    hash = "sha256-6ahaLolDeSdcpnoOgnOnhstrJBwSFKXCG22ZzH2+epU=";
    domain = "sr.ht";
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkg-config
    nim2
  ];

  buildInputs = [zlib] ++ (with curl; [out dev]);

  buildPhase = ''
    runHook preBuild
    make -j"''${NIX_BUILD_CORES}" release
    runHook postBuild
  '';

  installFlags = [
    "prefix=${placeholder "out"}"
    "manprefix=${placeholder "out"}/share/man"
  ];

  meta = with lib; {
    description = "A text-mode web browser";
    longDescription = ''
      A text-mode web browser. It displays websites in your terminal and allows you to navigate on them.
      It can also be used as a terminal pager.
    '';
    homepage = "https://sr.ht/~bptato/chawan/";
    license = licenses.unlicense;
    mainProgram = "cha";
  };
}
