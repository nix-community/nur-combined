{
  stdenv,
  vaculib,
}:
stdenv.mkDerivation {
  pname = "btw";
  version = "420.69.67";

  src = vaculib.path ./${stdenv.hostPlatform.system}.s;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    as -o btw.o "$src"
    ld -n -s --build-id=none -z noseparate-code -o btw btw.o
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv btw $out/bin/btw
  '';

  meta.mainProgram = "btw";
}
