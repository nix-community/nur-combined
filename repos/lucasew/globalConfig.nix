let
  cfg = rec {
      machine_name = "acer-nix";
      username = "lucasew";
      email = "lucas59356@gmail.com";
      # selectedDesktopEnvironment = "xfce_i3";
      selectedDesktopEnvironment = "gnome";
      hostname = "acer-nix";
      wallpaper = builtins.fetchurl {
        url = "http://wallpaperswide.com/download/armenia_syunik_khustup_hayk_k13-wallpaper-1366x768.jpg";
        sha256 = "1z2439f0d8hpqwjp07xhwkcp7svzvbhljayhdfssmvi619chlc0p";
      };
      # wallpaper = builtins.fetchurl {
      #   url = "http://wallpaperswide.com/download/aurora_sky-wallpaper-1366x768.jpg";
      #   sha256 = "1gk4bw5mj6qgk054w4g0g1zjcnss843afq5h5k0qpsq9sh28g41a";
      # };


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
          url = "https://github.com/NixOS/nixpkgs/archive/a52e974cff8fb80c427e0d55c01b3b8c770ccec4.tar.gz";
          sha256 = "0yhcnn435j9wfi1idxr57c990aihg0n8605566f2l8vfdrz7hl7d";
        };
        home-manager = builtins.fetchTarball {
          # master
          name = "home-manager";
          url = "https://github.com/nix-community/home-manager/archive/4cc1b77c3fc4f4b3bc61921dda72663eea962fa3.tar.gz";
          sha256 = "02y6bjakcbfc0wvf9b5qky792y9abyf1kgnk8r30f1advn3x69nc";
        };
        nur = builtins.fetchTarball {
          name = "NUR";
          url = "https://github.com/nix-community/NUR/archive/28fa0f70b53d00d33880645a3ec91301e715ba24.tar.gz";
          sha256 = "1xjrmlcry3yanm21cg0i1a2afdiqllynak539hl1n3nlm24kprmk";
        };
      };
      setupScript = import ./lib/generateDotfilerc.nix cfg;
  };
in cfg
