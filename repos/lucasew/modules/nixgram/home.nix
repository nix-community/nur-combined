{pkgs, ...}@args:
let 
  nixgram = import ./package.nix args;
in
{
  config = {
    systemd.user.services.nixgram = import ./service.nix args;
    home.packages = [
      nixgram
    ];
  };
}
