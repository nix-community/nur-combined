{
  description = "serpent213's NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.perplexity-ask.url = "github:serpent213/modelcontextprotocol";
  outputs =
    {
      self,
      nixpkgs,
      perplexity-ask,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system:
        (nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system})
        // {
          inherit (perplexity-ask.packages.${system}) perplexity-ask;
        }
      );
    };
}
