# The role of this file is to list which derivations should be built on CI.
# Example usage:
# - nix eval --json -f ci.nix 'pkgs-names-to-build'
# - nix eval --json -f ci.nix 'pkgs-to-build-with-deps'
{
  debug ? false
}:
let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/branch-off-24.11.tar.gz";
    sha256 = "1gx0hihb7kcddv5h0k7dysp2xhf1ny0aalxhjbpj2lmvj7h9g80a";
  }) {};
  isDerivation = nixpkgs.lib.isDerivation;
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isMaster = n: builtins.match "^.*-master$" n != null;
  wantToBuild = n: v: isDerivation v && isBuildable v && !(isMaster n);
  allInputs = p: builtins.filter (v: v!=null) (p.buildInputs ++ p.nativeBuildInputs ++ p.propagatedBuildInputs);
in

rec {
  default = import ./default.nix { inherit debug; };
  pkgs-to-build = default.pkgs.lib.filterAttrs wantToBuild default;
  pkgs-names-to-build = builtins.attrNames pkgs-to-build;
  pkgs-to-build-with-deps = default.pkgs.lib.mapAttrs (name: value: {derivation = value; inputs=allInputs value;}) pkgs-to-build;
}
