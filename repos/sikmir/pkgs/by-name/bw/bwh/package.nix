{
  lib,
  stdenv,
  fetchFromGitea,
  cmake,
  pkg-config,
  makeWrapper,
  SDL2,
  the-foundation,
  libX11,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bwh";
  version = "1.0.3";

  src = fetchFromGitea {
    domain = "git.skyjake.fi";
    owner = "skyjake";
    repo = "bwh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-POKjvUGFS3urc1aqOvfCAApUnRxoZhU725eYRAS4Z2w=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    SDL2
    the-foundation
  ]
  ++ lib.optional stdenv.isLinux libX11;

  installPhase = lib.optionalString stdenv.isDarwin ''
    runHook preInstall
    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/Bitwise\ Harmony.app/Contents/MacOS/Bitwise\ Harmony,bin/bitwise-harmony}
    runHook postInstall
  '';

  meta = {
    description = "Bitwise Harmony - simple synth tracker";
    homepage = "https://git.skyjake.fi/skyjake/bwh";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "bitwise-harmony";
  };
})
