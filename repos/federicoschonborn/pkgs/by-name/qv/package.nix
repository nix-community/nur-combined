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
  version = "5.2";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "qv-mirror";
    rev = "refs/tags/qv-${finalAttrs.version}";
    hash = "sha256-EZT2DU6jqERj+Uf0T4Xx3dnbDD4nEgidmV0L5wyWTaY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libtgd
    qt6.qtbase
  ] ++ lib.optional stdenv.hostPlatform.isLinux qt6.qtwayland;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  # Requires a graphical session.
  dontVersionCheck = true;

  strictDeps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "qv-(.*)"
    ];
  };

  meta = {
    mainProgram = "qv";
    description = "A a viewer for 2D data such as images, sensor data, simulations, renderings and videos";
    homepage = "https://marlam.de/qv/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
