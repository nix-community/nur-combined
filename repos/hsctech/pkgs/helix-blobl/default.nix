{
  lib,
  callPackage,
  pkgs,
  tree-sitter-grammars,
}:

let
  # Reuse nixpkgs' helix packaging (grammar lockfile, wrapper, runtime
  # assembly) instead of duplicating it here.
  nixpkgsHelixDir = pkgs.path + "/pkgs/by-name/he/helix";

  # nixpkgs' grammar lockfile, plus the bloblang grammar from blobl_sitter.
  lockedGrammars = (lib.importJSON (nixpkgsHelixDir + "/grammars.json")) // {
    bloblang = {
      nurl = {
        fetcher = "fetchFromCodeberg";
        args = {
          owner = "hsctech";
          repo = "blobl_sitter";
          rev = "e45bf9f42777ea4c8d353694118e30f34f2a0aa0"; # v0.2.4
          hash = "sha256-fFQ98/j0FofrR4MKTZxYqMgpKCM+KBwUe+Pi+il7Sb4=";
        };
      };
      subpath = null;
    };
  };
in
callPackage (nixpkgsHelixDir + "/package.nix") {
  inherit lockedGrammars;

  helix-unwrapped = callPackage ./unwrapped.nix { };

  # Add bloblang to the grammar scope; nixpkgs' own grammar fixes overlay
  # is still applied on top by the wrapper.
  tree-sitter-grammars = tree-sitter-grammars.overrideScope (
    _final: _prev: {
      tree-sitter-bloblang = callPackage ../tree-sitter-bloblang { };
    }
  );
}
