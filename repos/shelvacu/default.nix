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
  inherit (flake) inputs;
  lib = import "${inputs.nixpkgs}/lib";
  vaculib = import ./vaculib { inherit lib; };
  overlays = import ./overlays { inherit lib vaculib; };
  pkgs = import flake.inputs.nixpkgs { inherit system overlays; };
in
pkgs
// {
  nixpkgs-update =
    { ... }@args:
    import "${flake.inputs.nixpkgs}/maintainers/scripts/update.nix" (
      { include-overlays = overlays; } // args
    );
}
