{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  inherit (sources.drone-file-secret) pname version src;
  vendorHash = "sha256-5F831dsOw7BlqSJFLknp4lhsTPqv2suzWO+o3xX7Mnk=";

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Secret provider for Drone CI that reads secrets from a given folder";
    homepage = "https://github.com/xddxdd/drone-file-secret";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "drone-file-secret";
  };
})
