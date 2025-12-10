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

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  system.activationScripts.postActivation.text = ''
    # Enable Developer Mode for Terminal (allows debugging tools)
    echo "Enabling Developer Mode for Terminal..."
    spctl developer-mode enable-terminal

    echo "Muting Startup Chime"
    sudo nvram StartupMute=%01

    # 3. Block OCSP (Hosts File Modification)
    echo "Configuring Hosts file to block OCSP..."
    HOSTS_FILE="/etc/hosts"

    if ! grep -q "ocsp.apple.com" "$HOSTS_FILE"; then
      echo "127.0.0.1 ocsp.apple.com" | sudo tee -a "$HOSTS_FILE" > /dev/null
    fi
    
    if ! grep -q "ocsp2.apple.com" "$HOSTS_FILE"; then
      echo "127.0.0.1 ocsp2.apple.com" | sudo tee -a "$HOSTS_FILE" > /dev/null
    fi

    echo "Run spctl --master-disable if needed"
  '';

  # Auto upgrade nix package and the daemon service.
  nix = {
    enable = false;
    package = pkgs.nix;
  };
}
