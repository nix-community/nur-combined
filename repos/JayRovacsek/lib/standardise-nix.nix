{ self }:
let
  # This construct generates a suitable set for consumption when called that will ensure
  # repoducability of packages locally and externally via the pinning of nixpkg sources
  # to that of the requested stable/unstable split.
  #
  # This should also generate darwin settings dynamically based on passed packages and
  # omit darwin settings if in a Linux setting.
  #
  # The end product here is simply:
  # {
  #   environment.etc."nix/inputs/(darwin|linux)" = stable/unstable source
  #   nix.nixPath = [ required array of channel references stabilised to the above value ]
  # }
  #
  # Exposure of this however is via the self.outputs.lib.standardise-nix value as called in example below:
  # myStandardisedNix = self.outputs.lib.standardise-nix { pkgs = myPkgsSource; stable = true; }
  # 
  # Alternatively if you want to utilise unstable, just omit the stable flag entirely:
  # myStandardisedNix = self.outputs.lib.standardise-nix { pkgs = myPkgsSource; }
  #
  fn = { pkgs, stable ? false, ... }:
    let
      inherit (pkgs.lib) recursiveUpdate;

      darwinPinned = if stable then
        self.inputs.darwin-stable.outPath
      else
        self.inputs.darwin-unstable.outPath;
      nixpkgsPinned = if stable then
        self.inputs.stable.outPath
      else
        self.inputs.unstable.outPath;
      base = { environment.etc."nix/inputs/nixpkgs".source = nixpkgsPinned; };
      extra = if pkgs.stdenv.isDarwin then {
        environment.etc."nix/inputs/darwin".source = darwinPinned;
        nix.nixPath =
          [ "nixpkgs=/etc/nix/inputs/nixpkgs" "darwin=/etc/nix/inputs/darwin" ];
      } else {
        nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
      };
    in recursiveUpdate base extra;
in fn
