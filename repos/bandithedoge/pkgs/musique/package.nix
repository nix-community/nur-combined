{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  mpv,
  qt6,
  taglib,
  taglib_1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "musique";
  version = "1.12";
  src = fetchFromGitHub {
    owner = "flaviotordini";
    repo = "musique";
    rev = finalAttrs.version;
    hash = "sha256-KvvalelRWOwpOB6Hmr7WPTY4WjnAeBHXS+EhIEMqsus=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    mpv
    taglib_1
  ];

  postPatch = ''
    substituteInPlace musique.pro --replace-fail /usr/include/taglib ${taglib}/include/taglib
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A finely crafted music player";
    homepage = "https://flavio.tordini.org/musique";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Plus;
    broken = true; # taglib version mismatch or something
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
