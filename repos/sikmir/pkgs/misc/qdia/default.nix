{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qdia";
  version = "0.53";

  src = fetchFromGitHub {
    owner = "sunderme";
    repo = "qdia";
    tag = finalAttrs.version;
    hash = "sha256-iaobnEQm/viGAqHHlVf3LPV+MY16x1CFVQXLaVa/ddg=";
  };

  nativeBuildInputs = [
    cmake
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [ qt6.qtbase ];

  postInstall = lib.optionalString stdenv.isDarwin ''
    mv $out/{bin,Applications}
  '';

  meta = {
    description = "Simple schematic/diagram editor";
    homepage = "https://github.com/sunderme/qdia";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
