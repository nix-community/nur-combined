{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  validatePkgConfig,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "surgescript";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "alemart";
    repo = "surgescript";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-m6H9cyoUY8Mgr0FDqPb98PRJTgF7DgSa+jC+EM0TDEw=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  nativeInstallCheckInputs = [
    validatePkgConfig
    versionCheckHook
  ];

  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "surgescript";
    description = "A scripting language for games";
    homepage = "https://github.com/alemart/surgescript";
    changelog = "https://github.com/alemart/surgescript/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    pkgConfigModules = [
      "surgescript"
      "surgescript-static"
    ];
  };
})
