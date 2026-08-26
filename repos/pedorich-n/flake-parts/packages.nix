{
  self,
  inputs,
  ...
}:
{
  perSystem =
    {
      system,
      pkgs,
      lib,
      ...
    }:
    {
      packages = lib.mkMerge [
        (import ../packages.nix {
          inherit pkgs;
          inherit lib;
        })
        {
          docs = pkgs.callPackage ../dev/pkgs/docs-generate {
            ndg-builder = inputs.ndg.packages.${system}.ndg-builder.override { inherit (pkgs) ndg; };
            rev = self.shortRev or self.dirtyShortRev or "<unknown>";
            nixosModules = lib.attrValues self.modules.nixos;
          };
        }
      ];
    };
}
