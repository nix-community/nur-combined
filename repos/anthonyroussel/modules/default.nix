{
  hmModules = import ./home-manager;
  nixosModules = import ./nixos;
  nixosTests = import ./nixos/tests;
}
