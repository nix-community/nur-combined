{
  system ? builtins.currentSystem,
}:
let
  flakeCompat = (
    import
      (
        let
          lock = builtins.fromJSON (builtins.readFile ./flake.lock);
          nodeName = lock.nodes.root.inputs.flake-compat;
        in
        fetchTarball {
          url =
            lock.nodes.${nodeName}.locked.url
              or "https://github.com/edolstra/flake-compat/archive/${lock.nodes.${nodeName}.locked.rev}.tar.gz";
          sha256 = lock.nodes.${nodeName}.locked.narHash;
        }
      )
      {
        inherit system;
        src = ./.;
      }
  );
  flake = flakeCompat.outputs;
  overlays = flake.vacuOverlays;
  pkgs = flake.legacyPackages.${system}.stable;
in
pkgs
// {
  nixpkgs-update =
    { ... }@args:
    import "${pkgs.path}/maintainers/scripts/update.nix" (
      { include-overlays = overlays; } // args
    );
  inherit flake;
}
