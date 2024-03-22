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
  version = "0.5.6.1";

  src = fetchFromGitHub {
    owner = "alemart";
    repo = "surgescript";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0mgfam1zJfDGG558Vo1TysE2ehPD30XCP/j3GMnqN9w=";
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
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
