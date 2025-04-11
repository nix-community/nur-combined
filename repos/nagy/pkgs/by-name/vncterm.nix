{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  libvncserver,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vncterm";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "LibVNC";
    repo = "vncterm";
    rev = finalAttrs.version;
    hash = "sha256-6Lk9b4qi3jpJOxX578Jkq/zZ9N4Xmu2XL1Vsbs2goig=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ libvncserver ];

  meta = {
    homepage = "https://github.com/libvnc/vncterm";
    description = "Export virtual console sessions to any VNC client";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "linuxvnc";
  };
})
