{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.vgpu-unlock-rs)
    pname
    version
    rawVersion
    src
    ;

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    install -Dm644 ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unlock vGPU functionality for consumer grade GPUs";
    homepage = "https://github.com/mbilker/vgpu_unlock-rs";
    license = lib.licenses.mit;
  };
}
