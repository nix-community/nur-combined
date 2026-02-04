{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.sidestore-vpn) pname version src;

  cargoHash = "sha256-4O4C9D5URX1TiTGXTAhxFuGmShWvnzvHVNmciW5d9ZU=";

  meta = {
    changelog = "https://github.com/xddxdd/sidestore-vpn/releases/tag/v${finalAttrs.version}";
    mainProgram = "sidestore-vpn";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Allow SideStore to work across all iOS devices on your local network";
    homepage = "https://github.com/xddxdd/sidestore-vpn";
    license = lib.licenses.unlicense;
  };
})
