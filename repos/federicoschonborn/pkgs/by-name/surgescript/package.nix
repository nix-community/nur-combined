{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "surgescript";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "alemart";
    repo = "surgescript";
    rev = "v${finalAttrs.version}";
    hash = "sha256-m6H9cyoUY8Mgr0FDqPb98PRJTgF7DgSa+jC+EM0TDEw=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "surgescript";
    description = "A scripting language for games";
    homepage = "https://github.com/alemart/surgescript";
    changelog = "https://github.com/alemart/surgescript/blob/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
