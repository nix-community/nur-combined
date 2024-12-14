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
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mii-emu";
  version = "1.97";

  src = fetchFromGitHub {
    owner = "buserror";
    repo = "mii_emu";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-ugXPEENU2QKjF/R7MWes4rZuTVeyTfvSXhy/SnfPqJo=";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "mii_emu_gl";
    description = "MII Apple //e Emulator for Linux";
    homepage = "https://github.com/buserror/mii_emu";
    changelog = "https://github.com/buserror/mii_emu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
