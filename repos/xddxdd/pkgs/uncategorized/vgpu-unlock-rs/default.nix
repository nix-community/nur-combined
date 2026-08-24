{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "vgpu-unlock-rs";
  version = "2.5.0";
  rawVersion = "v2.5.0";
  src = fetchFromGitHub {
    owner = "mbilker";
    repo = "vgpu_unlock-rs";
    tag = "v2.5.0";
    hash = "sha256-5/cFc8JWgwxYm0JQX6aBGhIn2cNvGB4kh/w96P+lTgw=";
  };
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
