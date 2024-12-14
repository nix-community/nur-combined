{
  lib,
  sources,
  buildGoModule,
  xz,
}:
buildGoModule rec {
  inherit (sources.payload-dumper-go) pname version src;
  vendorHash = "sha256-XeD47PsFjDT9777SNE8f2LbKZ1cnL5HNPr3Eg7UIpJ0=";

  buildInputs = [ xz ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = lib.licenses.asl20;
    knownVulnerabilities = [
      "${pname} is available in nixpkgs by a different maintainer"
    ];
    mainProgram = "payload-dumper-go";
  };
}
