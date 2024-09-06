{ inputs, user, ... }:
{
  imports = [ inputs.preservation.nixosModules.default ];
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      files = [ ];
      directories = [
        # no /var since regular mount
      ];

      users = {
        root = {
          home = "/root";
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
          ];
          files = [
            ".bash_history"
          ];
        };
        ${user} = {
          files = [
            ".npmrc"
            ".mongoshrc.js"
            ".gitconfig"
            ".bash_history"
          ];
          directories = [
            "Src"
            "Books"
            "Documents"
            "Downloads"
            "Pictures"
            "Videos"
            "Music"
            "Tools"
            "Vault"
            {
              directory = "Sec";
              mode = "0700";
            }
            ".npm-packages"
            ".npm"
            ".pip"
            ".cache"
            ".local"
            ".mc"
            ".factorio"
            ".cargo"
            ".rustup"
            ".mozilla"
            ".FeelUOwn"
            ".config"
            ".mongodb"
            ".vscode"
            ".gradle"
            ".steam"
            "Android"
            "Games"
            {
              directory = ".gnupg";
              mode = "0700";
            }
            {
              directory = ".ssh";
              mode = "0700";
            }
          ];
        };
      };
    };
  };
}
