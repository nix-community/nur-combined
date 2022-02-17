{
  description = "nixcfg";

  inputs = {
    borderless-browser = {url =  "github:lucasew/borderless-browser.nix";           inputs.nixpkgs.follows = "nixpkgs"; };
    comma =              {url =  "github:Shopify/comma";                            flake = false;                      };
    dotenv =             {url =  "github:lucasew/dotenv";                           flake = false;                      };
    flake-utils =        {url =  "github:numtide/flake-utils/master";                                                   };
    home-manager =       {url =  "github:nix-community/home-manager/release-21.11"; inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence =       {url =  "github:nix-community/impermanence";               inputs.nixpkgs.follows = "nixpkgs"; };
    mach-nix =           {url =  "github:DavHau/mach-nix";                          inputs.nixpkgs.follows = "nixpkgs"; };
    nix-ld =             {url =  "github:Mic92/nix-ld";                             inputs.nixpkgs.follows = "nixpkgs"; };
    nix-vscode =         {url =  "github:lucasew/nix-vscode";                       flake = false;                      };
    nix-emacs =          {url =  "github:nixosbrasil/nix-emacs";                    flake = false;                      };
    nix-option =         {url =  "github:lucasew/nix-option";                       flake = false;                      };
    nix-on-droid =       {url =  "github:t184256/nix-on-droid/master";              inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; inputs.home-manager.follows = "home-manager"; };
    nixgram =            {url =  "github:lucasew/nixgram/master";                   flake = false;                      };
    nixos-hardware =     {url =  "github:NixOS/nixos-hardware";                     inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-generators =   {url =  "github:nix-community/nixos-generators";           inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs =            {url =  "github:NixOS/nixpkgs/nixos-unstable";                                                 };
    nur =                {url =  "github:nix-community/NUR/master";                 inputs.nixpkgs.follows = "nixpkgs"; };
    pocket2kindle =      {url =  "github:lucasew/pocket2kindle";                    flake = false;                      };
    redial_proxy =       {url =  "github:lucasew/redial_proxy";                     flake = false;                      };
    rust-overlay =       {url =  "github:oxalica/rust-overlay"; inputs.flake-utils.follows = "flake-utils"; inputs.nixpkgs.follows = "nixpkgs"; };
    send2kindle =        {url =  "github:lucasew/send2kindle";                      flake = false;                      };
  };

  outputs = { self, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: (
      let
        inherit (inputs)
        borderless-browser
        dotenv
        flake-utils
        home-manager
        nix-ld
        nix-vscode
        nixgram
        nixos-hardware
        nix-on-droid
        nur
        pocket2kindle
        redial_proxy
        ;
        inherit (builtins) replaceStrings toFile trace readFile concatStringsSep;
        inherit (home-manager.lib) homeManagerConfiguration;

        nixpkgs = inputs.nixpkgs.legacyPackages.${system}.applyPatches {
          name = "nixpkgs";
          src = inputs.nixpkgs;
          patches = map inputs.nixpkgs.legacyPackages.${system}.fetchpatch [
            {
              # fix remarshall
              url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/159074.patch";
              sha256 = "0mw667qrcwax66nx5bzfgaxyll4j2qkg1sp42ss860y8xyyyvjgv";
            }
          ];
        };

        pkgsArgs = {
          inherit overlays;
          config = {
            allowUnfree = true;
          };
        };

        mkPkgs = argfn: let
          stdargs = pkgsArgs // {inherit system;};
          in import nixpkgs (stdargs // (argfn stdargs));
        pkgs = mkPkgs (v: {});

        global = rec {
          username = "lucasew";
          email = "lucas59356@gmail.com";
          selectedDesktopEnvironment = "xfce_i3";
          rootPath = "/home/${username}/.dotfiles";
          rootPathNix = "${rootPath}";
          wallpaper = ./wall.jpg;
          system = throw "usa o system do flake!";
          environmentShell = ''
            export NIXPKGS_ALLOW_UNFREE=1
            export NIXCFG_ROOT_PATH="$HOME/.dotfiles"
            function nix-repl {
              nix repl "$NIXCFG_ROOT_PATH/repl.nix" "$@"
            }
            export LUA_PATH="${concatStringsSep ";" [
              "${pkgs.fennel}/share/lua/5.4.3/?.lua"
              "$NIXCFG_ROOT_PATH/scripts/?.lua"
              "$NIXCFG_ROOT_PATH/scripts/?/index.lua"
            ]}"
            export PATH="${concatStringsSep ":" [
              "$PATH"
              "$NIXCFG_ROOT_PATH/scripts/bin"
            ]}"
            export LUA_INIT="pcall(require, 'adapter.fennel')"
            export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=$NIXCFG_ROOT_PATH/compat/overlay.nix:home-manager=${home-manager}:nur=${nur}
          '';
        };

        extraArgs = {
          inherit self;
          inherit global;
          cfg = throw "your past self made a trap for non compliant code after a migration you did, now follow the stacktrace and go fix it";
        };

        docConfig = {options, ...}: # it's a mess, i might fix it later
        let
          pkgs = import nixpkgs {config = {allowBroken = true; inherit system; };};
          inherit (pkgs.nixosOptionsDoc { inherit options; })
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

      overlays = []
      ++ [(import "${home-manager}/overlay.nix")]
      ++ [(borderless-browser.overlay)]
      ++ [(import ./overlay.nix self)]
      ++ [inputs.rust-overlay.overlay]
      ;

      nixOnDroidConf = {mainModule}:
        import "${nix-on-droid}/modules" {
          config = {
            _module.args = extraArgs;
            home-manager.config._module.args = extraArgs;
            imports = [
              mainModule
            ];
          };
          pkgs = mkPkgs (super: {
            overlays = super.overlays ++ (import "${nix-on-droid}/overlays");
          });
          home-manager = import home-manager {};
          isFlake = true;
        };

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

      nixosConf = {
        mainModule,
        extraModules ? [],
      }:
      let
        revModule = {pkgs, ...}: {
          system.configurationRevision = if (self ? rev) then 
            trace "detected flake hash: ${self.rev}" self.rev
          else
            trace "flake hash not detected!" null;
          };
          source = {
          inherit pkgs system;
          modules = [
          revModule
          (mainModule)
          ] ++ extraModules;
          specialArgs = extraArgs;
          };
          eval = import "${nixpkgs}/nixos/lib/eval-config.nix";
          override = mySource: fn: let
            sourceProcessed = mySource // (fn mySource);
            evaluated = eval sourceProcessed;
            doc = docConfig evaluated;
          in evaluated // {
            source = sourceProcessed;
            inherit doc;
            override = override sourceProcessed;
          };
      in override source (v: {});

      in {
        inherit (global) environmentShell;
        inherit overlays;

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

        nixOnDroidConfigurations = {
          xiaomi = nixOnDroidConf {
            mainModule = ./nodes/xiaomi/default.nix;
          };
        };

        devShell = pkgs.mkShell {
          name = "nixcfg-shell";
          buildInputs = [];
          shellHook = ''
            ${global.environmentShell}
            echo Shell setup complete!
          '';
        };

        apps = {
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
        inherit extraArgs pkgs mkPkgs;
      }
    ));
}
