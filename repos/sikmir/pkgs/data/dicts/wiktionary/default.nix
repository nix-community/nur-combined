{ callPackage }:

{
  de-ru = callPackage ./base.nix {
    lang = "de-ru";
    version = "2021-04-30";
    hash = "sha256-uDDXd4lXf4VAsBMMcrf+zZrv8QexsU3M/CqzXGRmM9g=";
  };

  en-ru = callPackage ./base.nix {
    lang = "en-ru";
    version = "2021-05-05";
    hash = "sha256-UkBWRkpnG02K+7YOHTCx6T0u7UKbmFnsZpZcbriaS5E=";
  };

  fi-ru = callPackage ./base.nix {
    lang = "fi-ru";
    version = "2021-05-03";
    hash = "sha256-GUZmuj+23OVMwQT1jXVg7VvY7r/ERGOLax1dTwCv+ho=";
  };

  ru-be = callPackage ./base.nix {
    lang = "ru-be";
    version = "2021-01-21";
    hash = "sha256-VAkuG2T+IXzLSqJEmJ/VgGCNdUjxBEg90ECUWLeq6EE=";
  };

  ru-de = callPackage ./base.nix {
    lang = "ru-de";
    version = "2021-01-21";
    hash = "sha256-UrJTBDC99xoGNvVqYyU9QUzUESIaAVI0Btbu3I6PYU8=";
  };

  ru-en = callPackage ./base.nix {
    lang = "ru-en";
    version = "2021-01-21";
    hash = "sha256-Lip6ixKIO3xeu8ZXsWDkFAZONbjUp+LVI0bc3TnFxKQ=";
  };

  ru-eo = callPackage ./base.nix {
    lang = "ru-eo";
    version = "2021-01-21";
    hash = "sha256-NXWfv78JoR/K7Tkp7GdSS5OxVJspKbOixVTPzmAO2uQ=";
  };

  ru-fi = callPackage ./base.nix {
    lang = "ru-fi";
    version = "2021-01-21";
    hash = "sha256-BYW5I3WBbsjU4IupZDYjkMpAI5vDP27EC/yUvf0hirE=";
  };

  ru-sv = callPackage ./base.nix {
    lang = "ru-sv";
    version = "2021-01-21";
    hash = "sha256-AtKuseepJdW39yHuMAIksFroO6aWoqu+4fvDjb4pEO0=";
  };

  ru-uk = callPackage ./base.nix {
    lang = "ru-uk";
    version = "2021-01-21";
    hash = "sha256-pnHDgduoRcILJnegDcTpReXkIq8CDLw5nEX2H04pWvo=";
  };
}
