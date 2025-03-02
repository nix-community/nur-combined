{ pkgs, ... }:
{
  projectRootFile = "treefmt.nix";
  settings.global.excludes = [
    "LICENSE"
    "*.toml"
  ];

  programs.deadnix.enable = true;
  programs.mdsh.enable = true;
  programs.nixfmt.enable = true;
  programs.shellcheck.enable = pkgs.hostPlatform.system != "riscv64-linux";
  programs.shfmt.enable = pkgs.hostPlatform.system != "riscv64-linux";
  programs.yamlfmt.enable = true;
}
