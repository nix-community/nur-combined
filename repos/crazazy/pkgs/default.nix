{ sources ? import ../nix/sources.nix
, pkgs ? import sources.nixpkgs { }
}:
let
  monorepo = import ../. { inherit pkgs; };
  augmentCallPackage = callPackage: defaultArgs: fn: extraArgs: let
    f = if builtins.isFunction fn then fn else import fn;
    args = builtins.intersectAttrs (builtins.functionArgs f) defaultArgs;
  in
  callPackage f (args // extraArgs);
  nvsrcs = pkgs.callPackage ../nix/_sources/generated.nix { };
  callPackage = augmentCallPackage pkgs.callPackage { inherit nvsrcs sources; };
in
{
  # package sets
  js = import ./js { inherit pkgs; inherit (pkgs) nodejs; };
  firefox-addons = import ./firefox-addons { inherit pkgs; };

  # standalone packages
  seamonkey = callPackage ./seamonkey { };
  nix-gen-node-tools = callPackage ./gen-node-env { inherit (pkgs.nodePackages) node2nix;};
  nvfetcher = callPackage ./nvfetcher { };
  elm = callPackage ./elm { inherit (pkgs.elmPackages) elm; };
  enso = callPackage ./enso { };
  wasmfxtime = callPackage ./wasmfxtime { };
  cakeml = callPackage ./cakeml { };
  truffleSqueak = callPackage ./truffleSqueak { };

  # impure packages. These packages cannot get evaluated by NUR because they
  # contain some techniques that make the import -> eval -> build flow not possible without trying
  # to backtrack to a previous step
  hidden = {
    emacs = callPackage ./emacs { };
    grin = callPackage ./grin { };
    # hvm = callPackage ./HVM {};
    inherit monorepo;
  };
  # below package is borked again, leaving it out for now
  # ClassiCube = callPackage ./ClassiCube { };

  # modules
  modules = import ../modules;
  # overlays
  inherit (monorepo.lib) overlays;
  # lib functions
  lib = (import ../lib/utils.nix) // {
    serialize = import ../lib/serialize.nix;
    importFromSubmodules = import ../lib/importFromSubmodule.nix;
    inherit augmentCallPackage;
  };
}
