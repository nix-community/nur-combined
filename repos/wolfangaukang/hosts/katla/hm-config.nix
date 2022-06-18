{ username, system, overlays }:

inputs: {
  inherit system username;
  extraSpecialArgs = { inherit username; };
  homeDirectory = "/home/${username}";
  configuration = { ... }: {
    imports = [
      ./home-manager.nix
      ../../modules/home-manager/personal
    ];
    nixpkgs.overlays = overlays;
  };
}
