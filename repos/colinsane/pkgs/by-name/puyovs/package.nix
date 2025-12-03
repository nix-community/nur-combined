# TODO:
# - [ ] audio
# - [ ] test online mode
{
  alsa-lib,
  fetchFromGitHub,
  gitUpdater,
  libpulseaudio,
  libsForQt5,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "puyovs";
  version = "31";
  src = fetchFromGitHub {
    owner = "puyonexus";
    repo = "puyovs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HE7r8m0sDNdyNgQpcQAV7zBQmNy/GV0/uH+Sg7NXLLo=";
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.qt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = with libsForQt5; [
    alsa-lib
    libpulseaudio
    qtwayland
  ];

  postPatch = ''
     # sed -i "1i #define _POSIX_C_SOURCE 200809L" ENet/host.c
     # sed -i "1i #define _GNU_SOURCE 1" ENet/host.c
     # sed -i "1i #define _XOPEN_SOURCE 600" ENet/host.c
     # sed -i "10i #include <time.h>" ENet/host.c
     # i don't know why it fails to resolve the `time` symbol, but it's only used for seeding the RNG.
     substituteInPlace ENet/host.c \
       --replace-fail 'time(NULL)' 'enet_time_get()'
  '';

  # puyovs looks for its assets in $PWD, so launch it from its share directory
  qtWrapperArgs = [ "--chdir" "${placeholder "out"}/share/puyovs" ];

  NIX_CFLAGS_COMPILE = "-Wno-format-security";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    homepage = "https://github.com/puyonexus/puyovs";
    mainProgram = "puyovs";
  };
})
