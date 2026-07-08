{
  sources,
  version,
  hash,
  lib,
  buildGoModule,
}:
buildGoModule {
  inherit (sources) pname src;
  inherit version;
  vendorHash = hash;

  meta = {
    description = "Nix access-token management tool";
    homepage = "https://github.com/numtide/nix-auth";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "nix-auth";
  };
}
