{
  description = "oluceps' flake";
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      imports = [
        (inputs.import-tree ./mod)
      ];
    };
  inputs = {
    nixpkgs.url = "github:oluceps/nixpkgs/nixos-subids";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-rstable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-22.url = "github:NixOS/nixpkgs?rev=c91d0713ac476dfb367bbe12a7a048f6162f039c";
    nixpkgs-2505-kernel.url = "github:NixOS/nixpkgs?rev=c1a044ba6864653fa8cc7236fad37fa8a37917d3";
    nixpkgs-factorio.url = "github:NixOS/nixpkgs?rev=1b9bd8dd0fd5b8be7fc3435f7446272354624b01";
    nixpkgs-fix-mautrix.url = "github:NixOS/nixpkgs?rev=f6c9cba6ba89bd2d2f64c4a9e70e19b234784154";
    nixpkgs-origin-vaul.url = "github:NixOS/nixpkgs?rev=ccfbb9cd5859cc51c9d720b47b08e48d1aff633f";

    nix-topology.url = "github:oddlama/nix-topology";
    niri = {
      url = "github:YaLTeR/niri";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    browser-previews = {
      url = "github:nix-community/browser-previews";
    };
    # vaultix.url = "github:milieuim/vaultix";
    vaultix.url = "/home/riro/Src/vaultix";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lemurs = {
      url = "github:coastalwhite/lemurs";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    ascii2char = {
      url = "github:oluceps/nix-ascii2char";
    };
    # lix = {
    #   url = "git+https://git.lix.systems/lix-project/lix";
    #   flake = false;
    # };
    # lix-module = {
    #   url = "git+https://git.lix.systems/lix-project/nixos-module";
    #   inputs.lix.follows = "lix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    radicle = {
      url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tg-online-keeper.url = "github:oluceps/TelegramOnlineKeeper";
    # tg-online-keeper.url = "/home/elen/Src/tg-online-keeper";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    atuin = {
      url = "github:atuinsh/atuin";
    };
    conduit = {
      url = "github:matrix-construct/tuwunel?rev=f2c531429622dcc2f6bf96937e8e1def963cab79";
    };
    factorio-manager = {
      url = "github:asoul-rec/factorio-manager";
      # url = "/home/elen/Src/factorio-manager";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
    };
    # path:/home/riro/Src/flake.nix
    dae.url = "github:daeuniverse/flake.nix";
    # dae.url = "/home/elen/Src/flake.nix";
    nixyDomains.url = "github:oluceps/nixyDomains";
    nixyDomains.flake = false;
    nuenv.url = "github:DeterminateSystems/nuenv";
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    preservation.url = "github:WilliButz/preservation";
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    devenv.url = "github:cachix/devenv";
    pgvectors-nixpkgs.url = "github:NixOS/nixpkgs?rev=b468a08276b1e2709168a4d8f04c63360c2140a9";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.quickshell.follows = "quickshell"; # Use same quickshell version
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
    };
    online-exporter.url = "/home/riro/Src/monitou";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    # nix-kernelsu-builder.url = "/home/riro/Src/nix-kernelsu-builder";
    # "github:xddxdd/nix-kernelsu-builder";
    run0-sudo-shim = {
      url = "github:lordgrimmauld/run0-sudo-shim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nuanmonito.url = "/home/riro/Src/nuanmonito";
    ranet.url = "/home/riro/Src/ranet";
    ranet-discover.url = "/home/riro/Src/ranet-discover";
    import-tree.url = "github:vic/import-tree";
    self.submodules = true;

  };
}
