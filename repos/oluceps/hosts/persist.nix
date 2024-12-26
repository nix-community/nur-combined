{ inputs, user, ... }:
{
  imports = [
    inputs.preservation.nixosModules.default
    ./persist-base.nix
  ];
  preservation.preserveAt."/persist".users.${user} = {
    files = [
      ".npmrc"
      ".mongoshrc.js"
      ".gitconfig"
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
        directory = ".thunderbird";
        mode = "0700";
      }
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
}
