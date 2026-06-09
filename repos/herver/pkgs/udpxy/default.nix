{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "udpxy";
  version = "1.0-25.2";

  src = fetchFromGitHub {
    owner = "pcherenkov";
    repo = "udpxy";
    rev = finalAttrs.version;
    hash = "sha256-v+w4Y6MyJqUrgwuYUYTZW0Zn1jhW4vEpgBEQyEjvkzg=";
  };

  # The build files live in the chipmunk/ subdirectory.
  sourceRoot = "${finalAttrs.src.name}/chipmunk";

  # The bundled Makefile hard-codes -Werror --pedantic, which trips modern
  # GCC's -Wstringop-truncation; drop -Werror so the warnings are non-fatal.
  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CFLAGS=-Wno-error"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 udpxy -t $out/bin
    # udpxrec is the same binary; it switches behaviour on argv[0].
    ln -s udpxy $out/bin/udpxrec

    install -Dm644 doc/en/udpxy.1 -t $out/share/man/man1
    install -Dm644 doc/en/udpxrec.1 -t $out/share/man/man1

    runHook postInstall
  '';

  meta = {
    description = "Small-footprint daemon that relays UDP/RTP multicast streams to HTTP unicast clients";
    homepage = "https://github.com/pcherenkov/udpxy";
    changelog = "https://github.com/pcherenkov/udpxy/blob/${finalAttrs.version}/chipmunk/CHANGES";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "udpxy";
  };
})
