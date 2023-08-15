{pkgs, config, options, ...}:
{
  system.stateVersion = "21.05";
  time.timeZone = "America/Sao_Paulo";
  home-manager = {
    useGlobalPkgs = true;
    config = {...}: {
      home.stateVersion = "21.05";
      imports = [
        ../../homes/android/default.nix
      ];
    };
  };
  nix = {
    package = pkgs.nix;
    extraConfig = ''
      experimental-features = nix-command flakes
    '';
  };
}
