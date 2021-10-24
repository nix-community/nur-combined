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
    nix-vscode = {
      url = "github:lucasew/nix-vscode";
      flake = false;
    };
    mach-nix = {
      url = "github:DavHau/mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
  let
    inherit (inputs) nixpkgs nixpkgsLatest nixgram nix-ld home-manager dotenv nur pocket2kindle redial_proxy nixos-hardware borderless-browser nix-vscode;
    inherit (pkgs) nixosOptionsDoc;
    inherit (pkgs.lib) nixosSystem;
    inherit (builtins) replaceStrings toFile trace;
    inherit (home-manager.lib) homeManagerConfiguration;

    pkgs = import nixpkgs {
      inherit overlays;
      inherit (global) system;
      config = {
        allowUnfree = true;
      };
    };

    global = rec {
        username = "lucasew";
        email = "lucas59356@gmail.com";
        selectedDesktopEnvironment = "xfce_i3";
        rootPath = "/home/${username}/.dotfiles";
        rootPathNix = "${rootPath}";
        wallpaper = rootPath + "/wall.jpg";
        environmentShell = ''
          function nix-repl {
            nix repl "${rootPath}/repl.nix" "$@"
          }
          export NIXPKGS_ALLOW_UNFREE=1
          export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=${builtins.toString rootPath}/compat/overlay.nix:nixpkgsLatest=${nixpkgsLatest}:home-manager=${home-manager}:nur=${nur}:nixos-config=${(builtins.toString rootPath) + "/nodes/$HOSTNAME/default.nix"}
        '';
      system = "x86_64-linux";
    };

    extraArgs = {
      inherit self;
      inherit global;
      cfg = throw "your past self made a trap for non compliant code after a migration you did, now follow the stacktrace and go fix it";
    };

    docConfig = {options, ...}: # it's a mess, i might fix it later
    let
      inherit (nixosOptionsDoc { inherit options; })
        optionsAsciiDoc
        optionsJSON
        optionsMDDoc
        optionsNix
      ;
      normalizeString = content: 
        replaceStrings [".drv" "!bin!" "/nix"] ["" "" "//nix"] content;
      write = file: content:
        toFile file (normalizeString content);
    in {
      # How to export
      # NIXPKGS_ALLOW_BROKEN=1 nix-instantiate --eval -E 'with import <nixpkgs>; (builtins.getFlake "/home/lucasew/.dotfiles").nixosConfigurations.acer-nix.doc.mdText' --json | jq -r > options.md
      asciidocText = optionsAsciiDoc;
      # docbook is broken # cant export these as verbatim
      json = optionsJSON;
      # md = write "doc.md" optionsMDDoc;
      mdText = optionsMDDoc;
      nix = optionsNix;
    };

    overlays = [
      (import ./overlay.nix self)
      (import "${home-manager}/overlay.nix")
      (borderless-browser.overlay)
    ];

    hmConf = allConfig:
    let
      source = allConfig // {
        extraSpecialArgs = extraArgs;
        inherit pkgs;
      };
      evaluated = homeManagerConfiguration source;
      doc = docConfig evaluated;
    in evaluated // {
      inherit source doc;
    };

    nixosConf = {mainModule, extraModules ? []}:
    let
      revModule = {pkgs, ...}: {
        system.configurationRevision = if (self ? rev) then 
          trace "detected flake hash: ${self.rev}" self.rev
        else
          trace "flake hash not detected!" null;
      };
      source = {
        inherit pkgs;
        inherit (global) system;
        modules = [
          revModule
          (mainModule)
        ] ++ extraModules;
        specialArgs = extraArgs;
      };
      evaluated = import "${nixpkgs}/nixos/lib/eval-config.nix" source;
      doc = docConfig evaluated;
    in evaluated // {
      inherit source doc;
    };
  in {
    # inherit overlays;

      inherit (global) environmentShell;

      homeConfigurations = {
        main = hmConf {
          configuration = import ./homes/main/default.nix;
          homeDirectory = "/home/${global.username}";
          inherit (global) system username;
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

      devShell.x86_64-linux = pkgs.mkShell {
        name = "nixcfg-shell";
        buildInputs = [];
        shellHook = ''
        ${global.environmentShell}
        echo '${global.environmentShell}'
        echo Shell setup complete!
        '';
      };

      apps."${global.system}" = {
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

      templates = {
        # Does not work!
        hello = import ./templates/hello.nix;
      };

      inherit pkgs extraArgs;
    };
}
