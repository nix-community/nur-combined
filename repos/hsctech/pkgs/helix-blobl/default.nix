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
          rev = "81d932c9d8a37059bfff62f1215a6be25e688d23"; # main, post-v0.2.4
          hash = "sha256-4gjD9qqM6MuyjQ7VZeCm/pVAnyhh5MBITpo6DWwt/eg=";
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
