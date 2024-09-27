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
  version = "1.95";

  src = fetchFromGitHub {
    owner = "buserror";
    repo = "mii_emu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gRmdPtYz5cfEPOw2smv0+PHUJY6DhgFjfsZqFmKo0Zw=";
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
    changelog = "https://github.com/buserror/mii_emu/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
