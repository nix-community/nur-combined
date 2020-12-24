let
  cfg = rec {
      machine_name = "acer-nix";
      username = "lucasew";
      email = "lucas59356@gmail.com";
      # selectedDesktopEnvironment = "xfce_i3";
      selectedDesktopEnvironment = "xfce_i3";
      hostname = "acer-nix";
      dotfileRootPath = 
      let
        env = builtins.getEnv "DOTFILES";
        envNotNull = assert (env != ""); env;
        envExists = assert (builtins.pathExists envNotNull); envNotNull;
      in envExists;
      repos = {
        # nixpkgs = builtins.fetchTarball {
        #   name = "nixpkgs-20.09";
        #   url = "https://github.com/NixOS/nixpkgs/archive/1ae46bffe4a7cceae2f9c7ac629c3774369b7772.tar.gz";
        #   sha256 = "1ri1s3rkr0h6qir473syv8n6y9jgvhxhj6n7qca1ma4kc81v5cwx";
        # };
        nixpkgs = builtins.fetchTarball {
          name = "nixpkgs-unstable";
          url = "https://github.com/NixOS/nixpkgs/archive/57a787c9fa91f149c86a1ce83d57e07cfa589e07.tar.gz";
          sha256 = "1g759bvi0cb8yvwbmdlmix6b0qy1k2xpzpv4y43nczx9d3gyh7wz";
        };
        home-manager = builtins.fetchTarball {
          # master
          name = "home-manager";
          url = "https://github.com/nix-community/home-manager/archive/3627ec4de58d7fbda13c82dfec94eace10198f23.tar.gz";
          sha256 = "1dxhgsg7081c50h8z146lrhx6aj6f4h905f45im7ilj6c3q4z0z9";
        };
        nur = builtins.fetchTarball {
          name = "NUR";
          url = "https://github.com/nix-community/NUR/archive/ab31a663d0b28bdea14d51d744f37771597a6d7e.tar.gz";
          sha256 = "0bb6rw4n1xdj2km6m2j65j1bn7qszx0wsilklfp0vwy9y89i6kw1";
        };
        nix-ld = builtins.fetchTarball {
          name = "nix-ld";
          url = "https://github.com/Mic92/nix-ld/archive/60158bbc2afcbb0ece3183c5e01872d04773b9d0.tar.gz";
          sha256 = "086ls5mmhcyrkwgqjnzwa9ny0z2rixqb4rdpqk239i3jjaxpys5m";
        };
      };
      setupScript = import ./lib/generateDotfilerc.nix cfg;
  };
in cfg
