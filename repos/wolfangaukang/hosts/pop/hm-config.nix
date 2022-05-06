{ username, system, overlays }:
inputs: {
  inherit system username;
  homeDirectory = "/home/${username}";
  configuration = { ... }: {
    imports = [ ./home-manager.nix ];
    nixpkgs.overlays = overlays;
  };
}
