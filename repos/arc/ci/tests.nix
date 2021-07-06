{ arc, pkgs, ci }: with pkgs.lib; let
  tests = {
    overlays = let
      eval = import ./eval.nix { inherit pkgs; };
    in ci.command {
      name = "overlays";
      displayName = "overlay tests";

      failed = attrNames (filterAttrs (_: succ: !succ) eval);

      command = ''
        if [[ -z $failed ]]; then
          true
        else
          echo "Failed tests: $failed" >&2
          exit 1
        fi
      '';
    };
  };
in
builtins.attrValues tests
