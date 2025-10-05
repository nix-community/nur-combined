{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  ncurses,
  w3m,
  ueberzug,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cfiles";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "mananapr";
    repo = "cfiles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y5OOA0GGnjl4614zicuS00Wz2x5lLzhEHVioNFADQto=";
  };

  postPatch = ''
    substituteInPlace scripts/clearimg \
      --replace-fail "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg \
      --replace-fail "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg_uberzug \
      --replace-fail "ueberzug" "${ueberzug}/bin/ueberzug"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    ncurses
    w3m
    ueberzug
  ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "A ncurses file manager written in C with vim like keybindings";
    homepage = "https://github.com/mananapr/cfiles";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isDarwin; # ueberzug
  };
})
