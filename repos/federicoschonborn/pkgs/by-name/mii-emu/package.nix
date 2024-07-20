{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  libGLU,
  libglvnd,
  pixman,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mii-emu";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "buserror";
    repo = "mii_emu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-iCYQhiq3h1zZ5Odpf20GXDeP/W0BRNjNXzcm1yfeT9o=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    libGLU
    libglvnd
    pixman
    xorg.libX11
  ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  meta = {
    mainProgram = "mii_emu_gl";
    description = "MII Apple //e Emulator for Linux";
    homepage = "https://github.com/buserror/mii_emu";
    changelog = "https://github.com/buserror/mii_emu/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
