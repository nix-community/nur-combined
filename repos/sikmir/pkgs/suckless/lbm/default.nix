{
  lib,
  stdenv,
  fetchFromGitLab,
  pkg-config,
  dbus,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lbm";
  version = "0-unstable-2023-12-06";

  src = fetchFromGitLab {
    domain = "git.weitnahbei.de";
    owner = "nullmark";
    repo = "little_blue_man";
    rev = "d291e4e14df40fb84089e2dee25c3be50ea1366e";
    hash = "sha256-nsmW8wwOelzVmhtC5E2a5DPpEdaKiu98/wGl6Gflfz4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    xorg.libX11
    xorg.libXft
    xorg.libXinerama
  ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "A simple Bluetooth manager";
    homepage = "https://git.weitnahbei.de/nullmark/little_blue_man";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
