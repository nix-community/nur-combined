{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule {
  inherit (sources.pterodactyl-wings) pname version src;
  vendorHash = "sha256-eWfQE9cQ7zIkITWwnVu9Sf9vVFjkQih/ZW77d6p/Iw0=";

  meta = {
    mainProgram = "wings";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Server control plane for Pterodactyl Panel";
    homepage = "https://pterodactyl.io";
    license = lib.licenses.mit;
  };
}
