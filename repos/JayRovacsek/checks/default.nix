{ self, system }:
let
  pkgs = self.inputs.unstable.legacyPackages.${system};

  pre-commit-unsupported = [ "armv6l-linux" "armv7l-linux" ];
  checks = if builtins.elem system self.common.pre-commit-unsupported then
    { }
  else {
    pre-commit = self.inputs.pre-commit-hooks.lib.${system}.run
      (import ./pre-commit.nix { inherit self pkgs system; });
  };
in checks
