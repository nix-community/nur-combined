{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gwmp-mux";
  version = "0.11.0";
  src = fetchFromGitHub {
    owner = "helium";
    repo = "gwmp-mux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xSdheb7Io0b+CognG1SKF2GH8RaEsSdSjI2IkjiGSes=";
  };
  cargoHash = "sha256-0PsG81CuQcpzjJR3lhtCjE4tlD8tpyuzqIaRVS8U8cI=";

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/helium/gwmp-mux/releases/tag/v${finalAttrs.version}";
    mainProgram = "gwmp-mux";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Multiplexer for Semtech's GWMP over UDP";
    homepage = "https://github.com/helium/gwmp-mux";
    license = lib.licenses.asl20;
  };
})
