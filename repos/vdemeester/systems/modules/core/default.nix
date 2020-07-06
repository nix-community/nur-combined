{
  imports = [
    (import ../../../nix).home-manager
    ./home-manager.nix
    ./nix.nix
    ./nur.nix
    ./users.nix
  ];

  boot = {
    cleanTmpDir = true;
  };
}
