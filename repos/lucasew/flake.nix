{
  description = "nixcfg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgsLatest.url = "github:NixOS/nixpkgs/master";
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    borderless-browser = {
      url = "github:lucasew/borderless-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pocket2kindle = {
      url = "github:lucasew/pocket2kindle";
      flake = false;
    };
    send2kindle = {
      url = "github:lucasew/send2kindle";
      flake = false;
    };
    nixgram = {
      url = "github:lucasew/nixgram/master";
      flake = false;
    };
    dotenv = {
      url = "github:lucasew/dotenv";
      flake = false;
    };
    redial_proxy = {
      url = "github:lucasew/redial_proxy";
      flake = false;
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comma = {
      url = "github:Shopify/comma";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgsLatest, nixgram, nix-ld, home-manager, dotenv, nur, pocket2kindle, redial_proxy, nixos-hardware, borderless-browser, ... }@inputs:
  let
    cfg = rec {
        username = "lucasew";
        email = "lucas59356@gmail.com";
        selectedDesktopEnvironment = "xfce_i3";
        rootPath = "/home/${username}/.dotfiles";
        rootPathNix = "${rootPath}";
        wallpaper = rootPath + "/wall.jpg";
        environmentShell = ''
          function nix-repl {
            nix repl "${cfg.rootPath}/repl.nix" "$@"
          }
          export NIXPKGS_ALLOW_UNFREE=1
          export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=${builtins.toString cfg.rootPath}/compat/overlay.nix:nixpkgsLatest=${nixpkgsLatest}:home-manager=${home-manager}:nur=${nur}:nixos-config=${(builtins.toString cfg.rootPath) + "/nodes/$HOSTNAME/default.nix"}
        '';
      system = "x86_64-linux";
    };
    extraArgs = {
      inherit self;
      inherit cfg;
    };
    docConfig = {options, ...}: # it's a mess, i might fix it later
    with pkgs.nixosOptionsDoc { inherit options; };
    let
      normalizeString = content: builtins.replaceStrings [".drv" "!bin!" "/nix"] ["" "" "//nix"] content;
      write = file: content:
      let
        normalizedContent = normalizeString content;
        # filename = builtins.toFile file normalizedContent;
        filename = builtins.toFile file content;
      in filename;
      # in filename;
      # in "${filename}";
      # in pkgs.runCommandLocal file {} "cp ${filename} $out";
    in
    {
      # How to export
      # NIXPKGS_ALLOW_BROKEN=1 nix-instantiate --eval -E 'with import <nixpkgs>; (builtins.getFlake "/home/lucasew/.dotfiles").nixosConfigurations.acer-nix.doc.mdText' --json | jq -r > options.md
      ret = normalizeString "!bin!/eoq/trabson.drv.drv.drv";
      asciidocText = optionsAsciiDoc;
      # docbook is broken # cant export these as verbatim
      json = optionsJSON;
      # md = write "doc.md" optionsMDDoc;
      mdText = optionsMDDoc;
      # nix = optionsNix;
    };
    overlays = [
      (import ./overlay.nix self)
      (import "${home-manager}/overlay.nix")
      (borderless-browser.overlay)
    ];
    pkgs = import nixpkgs {
      inherit overlays;
      inherit (cfg) system;
      config = {
        allowUnfree = true;
      };
    };
    hmConf = {...}@allConfig:
    let
      config = allConfig // {
        extraSpecialArgs = extraArgs;
        inherit pkgs;
      };
      hmstuff = home-manager.lib.homeManagerConfiguration config;
      doc = docConfig hmstuff;
    in hmstuff // { inherit doc; source = config; };

    nixosConf = {mainModule, extraModules ? []}:
    let
      config = {
        inherit pkgs;
        inherit (cfg) system;
        modules = [
          revModule
          (mainModule)
        ] ++ extraModules;
        specialArgs = extraArgs;
      };
      evalConfig = import "${nixpkgs}/nixos/lib/eval-config.nix" config;
    in
    (nixpkgs.lib.nixosSystem config) // {doc = docConfig evalConfig; source = config; };

    revModule = ({pkgs, ...}: {
      system.configurationRevision = if (self ? rev) then 
        builtins.trace "detected flake hash: ${self.rev}" self.rev
      else
        builtins.trace "flake hash not detected!" null;
      });
    in {
      inherit overlays;
      inherit (cfg) environmentShell;
      homeConfigurations = {
        main = hmConf {
          configuration = import ./homes/main/default.nix;
          homeDirectory = "/home/${cfg.username}";
          inherit (cfg) system username;
        };
      };
      nixosConfigurations = {
        vps = nixosConf {
          mainModule = ./nodes/vps/default.nix;
        };
        acer-nix = nixosConf {
          mainModule = ./nodes/acer-nix/default.nix;
        };
        bootstrap = nixosConf {
          mainModule = ./nodes/bootstrap/default.nix;
        };
      };
      inherit pkgs;
      devShell.x86_64-linux = pkgs.mkShell {
        name = "nixcfg-shell";
        buildInputs = [];
        shellHook = ''
        ${cfg.environmentShell}
        echo '${cfg.environmentShell}'
        echo Shell setup complete!
        '';
      };
      apps."${cfg.system}" = {
        pkg = {
          type = "app";
          program = "${pkgs.pkg}/bin/pkg";
        };
        webapp = {
          type = "app";
          program = "${pkgs.webapp}/bin/webapp";
        };
        pinball = {
          type = "app";
          program = "${pkgs.wineApps.pinball}/bin/pinball";
        };
        wine7zip = {
          type = "app";
          program = "${pkgs.wineApps.wine7zip}/bin/7zip";
        };
      };
      inherit extraArgs;
    };
  }
