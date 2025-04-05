{
  # Used to find the project root
  projectRootFile = "flake.nix";

  # You can add formatters for your languages.
  # See https://github.com/numtide/treefmt-nix#supported-programs

  # Nix
  programs.nixfmt = {
    enable = true;
    excludes = [
      "ci.nix"
      "overlay.nix"
    ];
  };

  # GitHub Actions
  #programs.yamlfmt.enable = true;
  #programs.actionlint.enable = true;

  # Markdown
  programs.mdformat.enable = true;
}
