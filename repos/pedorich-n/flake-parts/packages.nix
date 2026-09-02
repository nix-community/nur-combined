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
    let
      attrs = import ../default.nix { inherit pkgs; };
      reserved = import ../reserved-names.nix;
    in
    {
      packages = lib.mkMerge [
        (removeAttrs attrs reserved)
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
