{ selfnur }:
rec {
  # create-ap = ./create-ap.nix;
  day-night-plasma-wallpapers = import ./day-night-plasma-wallpapers-nixos.nix {
    inherit (selfnur) day-night-plasma-wallpapers;
  };
  numworks = ./numworks.nix;
  phidget = ./phidget.nix;
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
  dolibarr = ./dolibarr/default.nix;
  simplehaproxy = ./simplehaproxy.nix;
  rpi-fan-serve = import ./rpi-fan-serve.nix {
    inherit simplehaproxy;
    inherit (selfnur) rpi-fan-serve;
  };
  unoconvservice = import ./unoconvservice.nix {
    inherit tfk-api-unoconv unoconv simplehaproxy;
  };
  smtprelay = import ./smtprelay.nix {
    inherit (selfnur) smtprelay;
  };
  protifygotify = import ./protifygotify.nix {
    inherit simplehaproxy;
  };
  hamiltonsamba = ./hamiltonsamba.nix;
  scottslounge = ./scottslounge.nix;
  hmModules = {
    day-night-plasma-wallpapers = import ./day-night-plasma-wallpapers-home-manager.nix {
      inherit (selfnur) day-night-plasma-wallpapers;
    };
    myvim = import ./myvim.nix {
      inherit (selfnur) 
          MyVimConfig
          kotlin-vim
          vim-lsp
          vim-lsp-settings
          vim-myftplugins
          vim-stanza
          vim-super-retab
          vim-vala
          decisive-vim;
    };
    redshift-auto = ./redshift-auto.nix;
    sync-database = ./sync-database.nix;
    pronotebot = ./pronotebot.nix;
    pronote-timetable-fetch = ./pronote-timetable-fetch.nix;
  };
}

