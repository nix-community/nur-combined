{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook3,
  zstd,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "outl";
  version = "1.0.12";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "outlmd";
    repo = "outl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PUB+4BcMWI7mzMxyQVgwlP8Wtv/b69Xf465yu12/Urk=";
  };

  doCheck = false; #IDGAF currently
  buildAndTestSubdir = "crates/outl-cli";

  cargoHash = "sha256-LAuFraKEq5Xx6fpXqki09aPQ6bbdO2vw3YxdOTunw54=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    zstd
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Local-first outliner. Markdown is the source of truth. Sync that doesn't corrupt your tree when two devices edit offline";
    homepage = "https://github.com/outlmd/outl";
    changelog = "https://github.com/outlmd/outl/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    platorms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "outl";
  };
})
