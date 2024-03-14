{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule {
  inherit (sources.pterodactyl-wings) pname version src;
  vendorHash = "sha256-LR4JuV73BWhXI97HGNH93Hd5NMU9PD84Rqfz4GOJzUs=";

  meta = with lib; {
    description = "The server control plane for Pterodactyl Panel.";
    homepage = "https://pterodactyl.io";
    license = licenses.mit;
  };
}
