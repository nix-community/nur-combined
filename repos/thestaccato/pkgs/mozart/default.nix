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
    rev = "98290e088f633e04eafde97e8225865be3b5838c";
    hash = "sha256-i1SLttBpVLFufX5DcPV2QlQGvshdFJCUWOB10O8zREw=";
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
