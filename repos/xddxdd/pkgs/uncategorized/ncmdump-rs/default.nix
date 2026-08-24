{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ncmdump-rs";
  version = "0.8.0";
  src = fetchFromGitHub {
    owner = "iqiziqi";
    repo = "ncmdump.rs";
    tag = "0.8.0";
    hash = "sha256-do11HeySNtNCOt9mhlqPwdyjm+86ujfI7n0blSqYtvM=";
  };
  cargoHash = "sha256-7Mqa0aa3Uv8JnviowmLJ6HgAQw+TmnW72CmDa1HyFZM=";

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/iqiziqi/ncmdump.rs/releases/tag/${finalAttrs.version}";
    mainProgram = "ncmdump";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "NetEase Cloud Music copyright protection file dump by rust";
    homepage = "https://github.com/iqiziqi/ncmdump.rs";
    license = lib.licenses.mit;
  };
})
