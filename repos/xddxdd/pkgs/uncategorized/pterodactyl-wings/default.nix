{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule {
  inherit (sources.pterodactyl-wings) pname version src;
  vendorHash = "sha256-LbXs5JBsXoHeKW0/TfmquWgJ0J9APLa25f2bAOkPhsY=";

  meta = {
    mainProgram = "wings";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Server control plane for Pterodactyl Panel";
    homepage = "https://pterodactyl.io";
    license = lib.licenses.mit;
  };
}
