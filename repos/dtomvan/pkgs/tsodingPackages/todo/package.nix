{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fasm,
}:
stdenvNoCC.mkDerivation {
  pname = "todo";
  version = "0-unstable-2023-09-24";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "todo.asm";
    rev = "b612947ff75afbdb217725cc51ceb307d9e8cfb1";
    hash = "sha256-UpjOGNxDWvFNSLNE1P2XxT4r0IX756bwAk4y6WSCMps=";
  };

  buildPhase = "${lib.getExe fasm} ./todo.asm; chmod +x ./todo";
  installPhase = "mkdir -p $out/bin; cp todo $out/bin";

  meta = {
    description = "Todo Web Application in flat assembler";
    homepage = "https://github.com/tsoding/todo.asm";
    license = lib.licenses.mit;
    mainProgram = "todo";
    platforms = [ "x86_64-linux" ];
  };
}
