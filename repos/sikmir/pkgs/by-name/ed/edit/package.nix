{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "edit";
  version = "0-unstable-2024-02-04";

  src = fetchFromGitHub {
    owner = "arthur-jacquin";
    repo = "edit";
    rev = "d0814100f003649c5afe3ec6cdd0c8d3fd7593f9";
    hash = "sha256-woFX3nGSOY4RSNPGRAt40xHDNOPlO2t1kgzb8U2v5+U=";
  };

  makeFlags = [
    "CC:=$(CC)"
    "LDFLAGS="
    "PREFIX=$(out)"
  ];

  meta = {
    description = "A suckless, simple, featured text editor";
    homepage = "https://github.com/arthur-jacquin/edit";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
