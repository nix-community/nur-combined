{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  gtk3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dragon";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mwh";
    repo = "dragon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wqG6idlVvdN+sPwYgWu3UL0la5ssvymZibiak3KeV7M=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ gtk3 ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Drag and drop source/target for X";
    homepage = "https://github.com/mwh/dragon";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
