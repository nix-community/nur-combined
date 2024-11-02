{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule rec {
  inherit (sources.drone-file-secret) pname version src;
  vendorHash = "sha256-5F831dsOw7BlqSJFLknp4lhsTPqv2suzWO+o3xX7Mnk=";

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Secret provider for Drone CI. It simply reads secrets from a given folder, suitable for private use Drone CI instances where running a Vault instance can be undesirable";
    homepage = "https://github.com/xddxdd/drone-file-secret";
    license = licenses.unfreeRedistributable;
  };
}
