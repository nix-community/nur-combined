{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  qt6,
  libtgd,
  # testers,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qv";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "qv-mirror";
    tag = "qv-${finalAttrs.version}";
    hash = "sha256-pFTihnJsD6g0NT6C6bdywokTW0yOrA1jlR0WQNE26mU=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libtgd
    qt6.qtbase
  ];

  strictDeps = true;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  # Requires a graphical session.
  dontVersionCheck = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=qv-(.*)" ]; };

  meta = {
    mainProgram = "qv";
    description = "A a viewer for 2D data such as images, sensor data, simulations, renderings and videos";
    homepage = "https://marlam.de/qv/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    inherit (libtgd.meta) broken;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
