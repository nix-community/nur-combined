{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ufat";
  version = "0.1.0-unstable-2026-11-13";

  src = fetchFromGitHub {
    owner = "systemd";
    repo = "ufat";
    rev = "d951666ec87f8d5bfba91d5ed6009ec7ed007aaa";
    hash = "sha256-Qz+kAhywNzr2/wKYs+9qUWky6Mw2CctSiZb8IZWD2H4=";
  };

  cargoHash = "sha256-U+GDhGY9bA88yMgwIMUicWm+INaEp7K9nxtIEYAajho=";

  checkFlags = [
    "--skip=sys::tests::fs_kind_tells_file_systems_apart"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/ufat --help || exit 2

    runHook postInstallCheck
  '';

  meta = {
    description = "Create, fill and check FAT32 file systems without mounting them";
    homepage = "https://github.com/systemd/ufat";
    license = lib.licenses.lgpl21Plus;
    mainProgram = "ufat";
    platforms = lib.platforms.linux;
  };
})
