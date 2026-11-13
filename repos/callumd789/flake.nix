{
  description = "Callum's personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      # x86_64-linux is the only system in use, and the only one CI builds.
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );
      # The same attributes as ./overlay.nix, but with the packages built against
      # this flake's locked nixpkgs. CI pushes those to Cachix, so a consumer
      # that doesn't make nixpkgs follow its own never builds them.
      overlays.default =
        final: prev:
        let
          nurPkgs = self.packages.${prev.stdenv.hostPlatform.system};
        in
        {
          inherit (nurPkgs) rustconn tmux-agent-sidebar;

          tmuxPlugins = prev.tmuxPlugins // {
            tmux-agent-sidebar = nurPkgs.tmux-agent-sidebar-plugin;
          };
        };
    };
}
