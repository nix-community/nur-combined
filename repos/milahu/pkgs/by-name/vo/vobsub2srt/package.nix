{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libtiff,
  leptonica,
  libpng,
  pkg-config,
  tesseract,
}:

stdenv.mkDerivation {
  pname = "vobsub2srt";
  version = "1.1.3-unstable-2026-07-01";

  src = fetchFromGitHub {
    owner = "ruediger";
    repo = "VobSub2SRT";
    # https://github.com/ruediger/VobSub2SRT/pull/108
    rev = "44b55903b19d72770566d375e7ee6048916410b6";
    hash = "sha256-TNuO4L96YUjFg5PSCPihht5ync/ePmFfWe3bA3BaKY0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    tesseract
    libtiff
    leptonica
    libpng
  ];

  propagatedBuildInputs = [
    tesseract
  ];

  postPatch = ''
    # fix: fatal error: libpng/png.h: No such file or directory
    substituteInPlace src/vobsub2srt.c++ \
      --replace \
        '#include <libpng/png.h>' \
        '#include <png.h>'
  '';

  meta = {
    homepage = "https://github.com/ruediger/VobSub2SRT";
    description = "Converts VobSub subtitles into SRT subtitles";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = [ ];
    mainProgram = "vobsub2srt";
  };
}
