{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdorfehs";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "jcs";
    repo = "sdorfehs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-efid6lRa8CTD+xObbop68hti5WRJReyKW57AmN7DS90=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = with xorg; [
    libX11
    libXft
    libXrandr
    libXtst
    libXi
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "A tiling window manager";
    homepage = "https://github.com/jcs/sdorfehs";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
