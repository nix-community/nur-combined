{ self, system }:
let
  name = "dev-shell";

  pkgs = self.inputs.stable.legacyPackages.${system};

  unsupportedSystem = builtins.elem system self.common.pre-commit-unsupported;

  nodePackages = with pkgs.nodePackages; [ prettier ];

  packages = if unsupportedSystem then
    [ ]
  else
    (with pkgs; [ nixfmt statix vulnix nil ]) ++ nodePackages;

  shellHook = if unsupportedSystem then
    ""
  else
    self.checks.${system}.pre-commit.shellHook;

  shell = { inherit name packages shellHook; };

in {
  "${name}" = pkgs.mkShell shell;
  default = self.outputs.devShells.${system}.${name};
}
