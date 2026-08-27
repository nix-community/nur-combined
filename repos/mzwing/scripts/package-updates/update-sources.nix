{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "update-sources";
    runtimeInputs = [
      pkgs.nix
      pkgs.nvfetcher
    ];
    text = builtins.readFile ./update-sources.sh;
  };
in {
  update-sources = {
    type = "app";
    program = "${script}/bin/update-sources";
    # Leave flake input updates to the weekly workflow.
    meta.description = "Update nvfetcher package sources";
  };
}
