{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule {
  inherit (sources.pterodactyl-wings) pname version src;
  vendorHash = "sha256-c/6PyfpBKYar0Dh1g5FmbcoXF92QXGw1l+/N9MrInJE=";

  meta = {
    mainProgram = "wings";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Server control plane for Pterodactyl Panel";
    homepage = "https://pterodactyl.io";
    license = lib.licenses.mit;
  };
}
