{ config, pkgs, ... }:

{
  #KEYCHRON KEYBOARD SWAP FN KEY
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  boot.kernelModules = [ "hid-apple"  ];

  #NIEUWE POGING
  boot.kernelParams = [
    "hid_apple.fnmode=2"
  ];

}
