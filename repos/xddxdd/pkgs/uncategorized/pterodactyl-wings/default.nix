{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule {
  inherit (sources.pterodactyl-wings) pname version src;
  vendorHash = "sha256-skwkFSEhOVSCcr/fPcee+5jfpGGGz307sCXMHV+rvBQ=";

  meta = {
    mainProgram = "wings";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Server control plane for Pterodactyl Panel";
    homepage = "https://pterodactyl.io";
    license = lib.licenses.mit;
  };
}
