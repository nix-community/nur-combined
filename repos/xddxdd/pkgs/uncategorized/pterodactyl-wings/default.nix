{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule {
  inherit (sources.pterodactyl-wings) pname version src;
  vendorSha256 = "sha256-fn+U91jX/rmL/gdMwRAIDEj/m0Zqgy81BUyv4El7Qxw=";

  meta = with lib; {
    description = "The server control plane for Pterodactyl Panel.";
    homepage = "https://pterodactyl.io";
    license = licenses.mit;
  };
}
