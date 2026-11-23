{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
  autoPatchelfHook,
  ocl-icd,
  libgcc,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rublk";
  version = "0.2.17";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ublk-org";
    repo = "rublk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nwSfMeAZJYSyGypDvsXFPE363AmJClY7a5qFADT6THI=";
  };

  cargoHash = "sha256-IR8++WBvPNuoGmWvCvTDLVmUbV0+9O04J9qsEWkKttY=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    autoPatchelfHook
  ];

  buildInputs = [ libgcc ];

  runtimeDependencies = [ ocl-icd ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust block device in userspace";
    homepage = "https://github.com/ublk-org/rublk";
    mainProgram = "rublk";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
