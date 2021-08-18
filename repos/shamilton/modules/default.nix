{ selfnur }:
rec {
  # create-ap = ./create-ap.nix;
  day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-nixos.nix;
  numworks = ./numworks.nix;
  slick-greeter = ./slick-greeter.nix;
  autognirehtet = import ./autognirehtet.nix {
    inherit (selfnur) autognirehtet;
  };
  rpi-fan = import ./rpi-fan.nix {
    inherit (selfnur) rpi-fan;
  };
  tfk-api-unoconv = import ./tfk-api-unoconv.nix {
    inherit (selfnur) tfk-api-unoconv;
  };
  unoconv = ./unoconv.nix;
  simplehaproxy = ./simplehaproxy.nix;
  unoconvservice = import ./unoconvservice.nix {
    inherit tfk-api-unoconv unoconv simplehaproxy;
  };
  protifygotify = import ./protifygotify.nix {
    inherit simplehaproxy;
  };
  hamiltonsamba = ./hamiltonsamba.nix;
  scottslounge = ./scottslounge.nix;
  hmModules = {
    day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-home-manager.nix;
    myvim = import ./myvim.nix {
      inherit (selfnur) 
          MyVimConfig
          kotlin-vim
          vim-lsp
          vim-lsp-settings
          vim-myftplugins
          vim-super-retab
          vim-vala;
    };
    redshift-auto = ./redshift-auto.nix;
    sync-database = ./sync-database.nix;
    pronotebot = ./pronotebot.nix;
    pronote-timetable-fetch = ./pronote-timetable-fetch.nix;
  };
}

