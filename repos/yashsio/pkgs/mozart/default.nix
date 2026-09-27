{
  lib,
  stdenv,
  fetchFromGitHub,
  ftxui,
  libvlc,
  sdbus-cpp_2,
}:

stdenv.mkDerivation {
  pname = "mozart";
  version = "v1.0.0-beta.1";

  src = fetchFromGitHub {
    owner = "yashsio";
    repo = "mozart";
    rev = "93aa0f9517f8d9efee01cad904e49779e61a97c5";
    hash = "sha256-M4//dstgv+pJnIhthG8PXGfyvTJB2ikJ9nrAjE8oQRI=";
  };

  buildInputs = [
    ftxui
    libvlc
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    sdbus-cpp_2
  ];

  makeFlags = lib.optionals stdenv.hostPlatform.isLinux [ "MPRIS=1" ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 mozart $out/bin/mozart
    runHook postInstall
  '';

  meta = {
    description = "Minimal and suckless TUI music player";
    homepage = "https://github.com/yashsio/mozart";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "mozart";
  };
}
