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
  callPackage = augmentCallPackage pkgs.callPackage { inherit sources; };
in
{
  # package sets
  js = import ./js { inherit pkgs; };
  firefox-addons = import ./firefox-addons { inherit pkgs; };

  # standalone packages
  seamonkey = callPackage ./seamonkey { };
  nix-gen-node-tools = callPackage ./gen-node-env { inherit (pkgs.nodePackages) node2nix;};
  elm = callPackage ./elm { inherit (pkgs.elmPackages) elm; };
  hvm = callPackage ./HVM {};
  # vendor broken. Also in nixpkgs already
  # efm-langserver = callPackage ./efm-langserver { };
  guile-hall = callPackage ./guile-hall { };
  # for some reason unzip malfunctions on this right now. will check later
  truffleSqueak = callPackage ./truffleSqueak { };

  # impure packages. These packages cannot get evaluated by NUR because they
  # contain some techniques that make the import -> eval -> build flow not possible without trying
  # to backtrack to a previous step
  hidden = {
    emacs = callPackage ./emacs { };
    grin = callPackage ./grin { };
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
