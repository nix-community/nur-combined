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
  version = "unstable";

  src = fetchFromGitHub {
    owner = "yashsio";
    repo = "mozart";
    rev = "cad1d6e12cda9f003addb6c0db4927ba7a038c04";
    hash = "sha256-zBXweMh4+4n0MAOjlDawkXKR4VtttSRYrFxUYHWwSGw=";
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
