{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,

  withPortaudio ? false,
  withJack ? true,

  pkg-config,
  libsndfile,
  cairo,
  libx11,
  lv2,
  jack2,
  portaudio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ratatouille.lv2";
  version = "0.9.11";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "Ratatouille.lv2";
    fetchSubmodules = true;
    rev = "v${finalAttrs.version}";
    hash = "sha256-mig3yUGSNz1xuyz6ljKqJUjNqmEcsbXSH1vTxTGdOFk=";
  };

  postPatch = ''
    substituteInPlace Ratatouille/makefile \
      --replace-fail "-flto=auto" ""
  '';

  makeFlags = [
    "INSTALL_DIR=${placeholder "out"}/lib/lv2"
    "EXE_INSTALL_DIR=${placeholder "out"}/bin"
    "CLAP_INSTAL_DIR=${placeholder "out"}/lib/clap"
    "VST2_INSTAL_DIR=${placeholder "out"}/lib/vst2"
  ];

  dontStrip = true;

  nativeBuildInptus = [
    autoPatchelfHook
  ];

  buildInputs = [
    pkg-config
    libsndfile
    cairo
    libx11
    lv2
    cairo
  ]
  ++ lib.optionals withPortaudio [
    portaudio
  ]
  ++ lib.optionals withJack [
    jack2
  ];

  meta = with lib; {
    description = "Ratatouille is a Neural Model loader and mixer for Linux/Windows";
    homepage = "https://github.com/brummer10/Ratatouille.lv2";
    license = licenses.bsd3;
    maintainers = with maintainers; [ bryanhonof ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
    mainProgram = "Ratatouille";
  };
})
