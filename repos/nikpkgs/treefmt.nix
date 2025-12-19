_: {
  # Project root
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true; # Formatter
    statix.enable = true; # Linter
    deadnix.enable = true; # Dead code detect
  };

  settings = {
    global.excludes = [ "_sources/*" ];
  };
}
