{ ... }:

{
  nix-homebrew = {
    # User owning the Homebrew prefix
    user = "admin";

    # Automatically migrate existing Homebrew installations
    # autoMigrate = true;
  };

  homebrew = {
    brews = [ "python3" ];

    casks = [
      # broken on nixpkgs darwin
      "ghostty"

      # not available on nixpkgs darwin

    ];
  };
}
