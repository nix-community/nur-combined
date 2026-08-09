{
  nix-homebrew = {
    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = "iamanaws";

    # Automatically migrate existing Homebrew installations
    # autoMigrate = true;
  };

  homebrew = {
    brews = [ ];

    casks = [
      # pending to migrate
      "google-chrome"

      # broken on nixpkgs
      "flameshot"
      "spotify"

      # not available on nixpkgs darwin
      "clickup"
      # "logi-options+"
    ];
  };
}
