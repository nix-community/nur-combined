{ inputs, lib, pkgs, ... }:
{
  programs.zsh.enable = true;
  users.users.avy.shell = pkgs.zsh;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "bak";
    users.avy = {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.homeModules.nix-index
        ../../../modules/secrets/home.nix
        ../../../users/avy/sops.nix
        ../../../users/avy/dotfiles/shell/default.nix
        ../../../users/avy/dotfiles/editor/default.nix
      ];

      # User services cannot read the host's root-only SSH key.
      sops.age.sshKeyPaths = lib.mkForce [ ];

      dots.shell.enable = true;
      dots.editor.enable = true;

      home = {
        username = "avy";
        homeDirectory = "/home/avy";
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
    };
  };
}
