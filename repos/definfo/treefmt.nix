{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    ".github/**"
    "_sources/**"
    "LICENSE"
    "*.toml"
  ];

  # Nix
  programs.nixfmt.enable = true;
  programs.nixfmt.package = pkgs.nixfmt-rfc-style;
  # Shell
  programs.shellcheck.enable = true;
  # Markdown
  programs.mdformat.enable = true;
  # GitHub Actions
  # programs.actionlint.enable = true;
}
