{
  flake,
  system,
  writers,
  lib,
}:
let
  nurPackages = lib.removeAttrs flake.packages.${system} [ "docs" ];

  nurPackagesMetadata = lib.mapAttrsToList (_: p: {
    name = p.pname or (lib.getName p.name);
    version = p.version or (lib.getVersion p.name);
    homepage = (p.meta or { }).homepage or null;
    description = (p.meta or { }).description or null;
  }) nurPackages;

  nixosModulesMetadata = lib.attrNames flake.modules.nixos;
in
writers.writeJSON "nur-packages-meta.json" {
  packages = nurPackagesMetadata;
  nixosModules = nixosModulesMetadata;
}
