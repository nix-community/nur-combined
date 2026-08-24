{
  fetchFromGitHub,
  lib,
  rustPlatform,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vgpu-unlock-rs";
  version = "2.5.0";
  src = fetchFromGitHub {
    owner = "mbilker";
    repo = "vgpu_unlock-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5/cFc8JWgwxYm0JQX6aBGhIn2cNvGB4kh/w96P+lTgw=";
  };
  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--generate-lockfile" ];
  };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unlock vGPU functionality for consumer grade GPUs";
    homepage = "https://github.com/mbilker/vgpu_unlock-rs";
    license = lib.licenses.mit;
  };
})
