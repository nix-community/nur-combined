{ darwin-workstation, username }:
{ pkgs, home-manager, ... }: {
  networking = {
    hostName = darwin-workstation;
    localHostName = darwin-workstation;
    computerName = darwin-workstation;
  };  

  # Define user 
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Configure zsh as an interactive shell.
  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = (import ./home.nix { inherit username; });
  };

  # Enable flakes and optimise store during every build
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  # Auto upgrade nix package and the daemon service.
  nix = {
    enable = true;
    package = pkgs.nix;
  };
}
