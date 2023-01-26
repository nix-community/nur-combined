defaultPackages: with defaultPackages.pkgs; {
  rMaker = import ./rMaker.nix;
  python-personal = (import ./python-env.nix) python310;

  rEnv = rMaker defaultPackages.rWrapper rPackages;

  crazazy = import ../../pkgs { inherit (defaultPackages) pkgs; };

  all-env = buildEnv {
    name = "all-env";
    paths = [ user-env dev-env games-env js-env ];
  };

  user-env = buildEnv {
    name = "user-env";
    paths = [
      firefox-esr
      gparted
      xclip
      # broken rn
      # spectral
      xbanish
      vlc
      ffmpeg
      libreoffice
      evince
      (wine.override { wineBuild = "wineWow"; })
    ];
  };

  dev-env = buildEnv {
    name = "dev-env";
    paths = [
      git
      jq
      crazazy.hidden.emacs
      python-personal
      sage
      nodejs_latest
      racket
      rEnv
      jetbrains.pycharm-community
      jetbrains.idea-community
    ];
  };

  js-env = buildEnv {
    name = "js-env";
    paths = with crazazy.js; [
      tldr
      npe
      jspm
    ];
  };

  games-env = buildEnv {
    name = "games-env";
    paths = [
      minetest
      polymc
      steam
      stuntrally
    ];
  };
}
