{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
  autoPatchelfHook,
  ocl-icd,
  libgcc,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rublk";
  version = "0.2.15";

  src = fetchFromGitHub {
    owner = "ublk-org";
    repo = "rublk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TOIgYJmKyn0ezsqky42SoqrRheL5H7ZPjUo980naJ/Y=";
  };

  cargoHash = "sha256-6bjyE/K+l6uvkjBZuRpZyCnL8D/uT8LVi9Q1l7TtU58=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    autoPatchelfHook
  ];

  buildInputs = [ libgcc ];

  runtimeDependencies = [ ocl-icd ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Rust block device in userspace";
    homepage = "https://github.com/ublk-org/rublk";
    mainProgram = "rublk";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
