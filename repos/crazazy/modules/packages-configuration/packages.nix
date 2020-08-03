defaultPackages: with defaultPackages.pkgs; {
  rMaker = import ./rMaker.nix;
  python-personal = (import ./python-env.nix) python37;

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
      gomuks
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
      python-personal
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
      multimc
      steam
      stuntrally
    ];
  };
}
