{
  lib,
  fetchFromGitHub,
  fetchurl,
  stdenvNoCC,
  linuxHeaders,
  glibc,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "filc-pizfix";
  version = "0.683";

  src = fetchurl {
    url = "https://github.com/pizlonator/fil-c/releases/download/v${finalAttrs.version}/filc-${finalAttrs.version}-linux-x86_64.tar.xz";
    hash = "sha256-D7whNa0w1bCt8xKJvMbw2gzI2yMj9OrCl41fg1ONEMY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv ./build ./pizfix $out

    mkdir $out/pizfix/os-include
    ln -s ${linuxHeaders} $out/pizfix/os-include/linux
    ln -s ${glibc.dev}/include/asm $out/pizfix/os-include/asm
    ln -s ${glibc.dev}/include/asm-generic $out/pizfix/os-include/asm-generic

    ln -s build/bin $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Fil-C toolchain (Pizfix)";
    longDescription = ''
      Fil-C is a memory-safe implementation of C and C++.

      This derivation packages the Pizfix distribution, which contains the
      filcc and fil++ compilers and required libraries and headers.
    '';
    homepage = "https://fil-c.org/pizfix";
    downloadPage = "https://github.com/pizlonator/fil-c/releases/tag/v${finalAttrs.version}";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    badPlatforms = [
      "aarch64-linux"
    ];
    sourceProvenance = [
      lib.sourceTypes.binaryNativeCode
    ];
    license = with lib.licenses; [
      # compiler
      (WITH asl20 llvm-exception)
      # libpas
      (AND [
        bsd2 # the library
        bsd3 # setproctitle
      ])
    ];
    mainProgram = "filcc";
  };

})
