{ lib, stdenv, fetchFromGitLab, pkg-config, dbus, xorg }:

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

  buildInputs = [ dbus xorg.libX11 xorg.libXft xorg.libXinerama ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple Bluetooth manager";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
