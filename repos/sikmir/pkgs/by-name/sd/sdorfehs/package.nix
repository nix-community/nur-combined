{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libx11,
  libxft,
  libxrandr,
  libxtst,
  libxi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdorfehs";
  version = "1.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jcs";
    repo = "sdorfehs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-efid6lRa8CTD+xObbop68hti5WRJReyKW57AmN7DS90=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxtst
    libxi
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
