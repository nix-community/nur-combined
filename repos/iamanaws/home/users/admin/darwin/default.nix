{ ... }:

{
  # You can import other home-manager modules here
  imports = [
    ../default.nix
    ../../iamanaws/config/shell
    ../../iamanaws/config/shell/zsh.nix
  ];

  home = {
    username = "admin";
    homeDirectory = "/Users/admin";
  };
}
