{
  curl,
  fetchFromSourcehut,
  lib,
  nim2,
  pkg-config,
  stdenv,
  zlib,
}:
stdenv.mkDerivation {
  pname = "chawan";
  version = "unstable-2023-10-15";
  src = fetchFromSourcehut {
    owner = "~bptato";
    repo = "chawan";
    rev = "ab6dad2bcc77450e3ded9f5b303662aae978c4e4";
    hash = "sha256-L1L4eHqSwQFoM+Md1Qi8e/fzfEIqg1O6cSLDJPxzHIc=";
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
