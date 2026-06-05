# copies into some archive directory the entire closure to build a given derivation.
# i.e. even without a store or network access, the archive directory contains everything necessary
# to go from bootstrap to derivation output.
#
# usage:
# ```
# cat <<EOF >nix-archive.toml
# binary_cache_dir = "/home/colin/nixos/build/pynixos-archive/"
# copy_command = [ "nix", "copy", "--to", "file:///home/colin/nixos/build/pynixos-archive/" ]
# EOF
# nix-build -A pynixos.pynixos
# ./result/bin/pynixos 'nixpkgs#hello'
# ```
{
  fetchFromGitea,
  pkgs,
  nix-update-script,
}:
let
  version = "0-unstable-2026-06-01";
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "shelvacu";
    repo = "pynixos";
    rev = "c86e60b94a54982ee410cdee4e788bedc4a6ee61";
    hash = "sha256-ovCzNLPcrvaBwlqG/Fwyoajs7UyCQvw+GkU8LN4Nuro=";
  };
  overlay = import "${src}/overlay.nix";
  finalPkgs = pkgs.extend overlay;
  inherit (finalPkgs.python314Packages) pynixos;
in
  src.overrideAttrs (base: {
    # attributes required by update scripts
    pname = "pynixos";
    inherit src version;

    passthru = base.passthru // {
      inherit overlay pynixos;
      pkgs = overlay finalPkgs pkgs;
      updateScript = nix-update-script {
        extraArgs = [ "--version" "branch" ];
      };
    };
  })
