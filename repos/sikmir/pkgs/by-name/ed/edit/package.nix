{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "edit";
  version = "0-unstable-2026-02-19";

  src = fetchFromSourcehut {
    owner = "~arthur-jacquin";
    repo = "edit";
    rev = "f23ba2414daaa0e5e9c794dde67cfb32a301de15";
    hash = "sha256-AtAR9WnJ4+R1ic0tayA//3DNrAJet6w2ma7zUbAQjcY=";
  };

  makeFlags = [
    "CC:=$(CC)"
    "LDFLAGS="
    "PREFIX=$(out)"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result";

  meta = {
    description = "A suckless, simple, featured text editor";
    homepage = "https://github.com/arthur-jacquin/edit";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
