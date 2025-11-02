{
  # Used to find the project root
  projectRootFile = "flake.nix";

  # Enable formatters
  programs.alejandra.enable = true;
  programs.prettier.enable = true;
}
