pkgs:
let
  internal-inputs = builtins.mapAttrs (
    _name: node: builtins.getFlake (builtins.flakeRefToString node.locked)
  ) (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes;
  treefmtEval = internal-inputs.treefmt-nix.lib.evalModule pkgs treefmtConfig;

  treefmtConfig = {
    projectRootFile = "flake.nix";
    # keep-sorted start
    programs.actionlint.enable = true;
    programs.deadnix.enable = true;
    programs.keep-sorted.enable = true;
    programs.nixfmt.enable = true;
    programs.prettier.enable = true;
    programs.statix.enable = true;
    # keep-sorted end
  };
in
treefmtEval.config.build
