{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
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
    tag = "v${finalAttrs.version}";
    hash = "sha256-ugXPEENU2QKjF/R7MWes4rZuTVeyTfvSXhy/SnfPqJo=";
  };

  patches = [
    # Fix building on ARM.
    (fetchpatch2 {
      url = "https://github.com/buserror/mii_emu/commit/cb27727bb2f8270fcb6545b3514d9f85b99f731c.patch";
      hash = "sha256-YuKaJieK2dXr32Cn+dEOmZp1hPZoxdUmVkgQzYly/8c=";
    })
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libGLU
    libglvnd
    pixman
    xorg.libX11
  ];

  strictDeps = true;

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "mii_emu_gl";
    description = "MII Apple //e Emulator for Linux";
    homepage = "https://github.com/buserror/mii_emu";
    changelog = "https://github.com/buserror/mii_emu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
