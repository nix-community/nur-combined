# this overlay exists specifically to control the order in which other overlays are applied.
# for example, `pkgs` *must* be added before `cross`, as the latter applies overrides
# to the packages defined in the former.
let
  patches = import ./patches.nix;
  pkgs' = import ./pkgs.nix;
  preferences = builtins.listToAttrs
    (map
      (file: {
        name = builtins.head (builtins.match "^(.*)\\.nix$" file);
        value = import ./preferences/${file};
      })
      (builtins.attrNames (builtins.readDir ./preferences))
    );
  cross = import ./cross.nix;
  musl = import ./musl.nix;
  static = import ./static.nix;
  strict = import ./strict.nix;
  pkgs-ccache = import ./pkgs-ccache.nix;
  pkgs-debug = import ./pkgs-debug.nix;
in
let
  isCross = pkgs: !(pkgs.lib.systems.equals pkgs.stdenv.hostPlatform pkgs.stdenv.buildPlatform);
  isMusl = pkgs: pkgs.stdenv.hostPlatform.isMusl;
  isStatic = pkgs: pkgs.stdenv.hostPlatform.isStatic;
  isStrict = pkgs: pkgs.config.strictDepsByDefault or false;
  optional = condition: overlay: final: prev:
    prev.lib.optionalAttrs (condition prev) (overlay final prev);
in
  [
    patches
    pkgs'
  ]
  ++ [
    preferences.electron-bin
    preferences.misc
    preferences.no-opengl-indirection
    preferences.no-perl
    preferences.reduce-closure
  ]
  ++ [
    (optional isCross cross)
    (optional isMusl musl)
    (optional isStatic static)
    (optional isStrict strict)
    pkgs-ccache
    pkgs-debug
  ]
