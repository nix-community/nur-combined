{
  description = "nixcfg";

  inputs = {
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld.url = "github:Mic92/nix-ld";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgsLatest.url = "github:NixOS/nixpkgs/master";
    nur.url = "github:nix-community/NUR/master";
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
    };
  };

  outputs = { self, nixpkgs, nixpkgsLatest, nixgram, nix-ld, home-manager, dotenv, nur, pocket2kindle, redial_proxy, nixos-hardware, ... }@inputs:
  with import ./globalConfig.nix;
  let
    system = "x86_64-linux";
    environmentShell = ''
      function nix-repl {
        nix repl "${rootPath}/repl.nix" "$@"
      }
      export NIXPKGS_ALLOW_UNFREE=1
      export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=${builtins.toString rootPath}/compat/overlay.nix:nixpkgsLatest=${nixpkgsLatest}:home-manager=${home-manager}:nur=${nur}:nixos-config=${(builtins.toString rootPath) + "/nodes/$HOSTNAME/default.nix"}
    '';

    hmConf = {...}@allConfig:
    let
      hmstuff = home-manager.lib.homeManagerConfiguration allConfig;
      doc = docConfig hmstuff;
    in hmstuff // { inherit doc; };

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
    nixosConf = {mainModule, extraModules ? []}:
    let
      config = {
        inherit pkgs;
        inherit system;
        modules = [
          revModule
          (mainModule)
        ] ++ extraModules;
      };
      evalConfig = import "${nixpkgs}/nixos/lib/eval-config.nix" config;
    in
    (nixpkgs.lib.nixosSystem config) // {doc = docConfig evalConfig;};
    overlays = [
      (import ./overlay.nix)
      (import "${home-manager}/overlay.nix")
    ];
    pkgs = import nixpkgs {
      inherit overlays;
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    revModule = ({pkgs, ...}: {
      system.configurationRevision = if (self ? rev) then 
        builtins.trace "detected flake hash: ${self.rev}" self.rev
      else
        builtins.trace "flake hash not detected!" null;
      });
    in {
      inherit overlays;
      inherit environmentShell;
      homeConfigurations = {
        main = hmConf {
          configuration = import ./homes/main/default.nix;
          inherit system;
          homeDirectory = "/home/${username}";
          inherit username;
          inherit pkgs;
        };
      };
      nixosConfigurations = {
        vps = nixosConf {
          mainModule = ./nodes/vps/default.nix;
        };
        acer-nix = nixosConf {
          mainModule = ./nodes/acer-nix/default.nix;
          extraModules = [
            nix-ld.nixosModules.nix-ld
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
          ];
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
        ${environmentShell}
        echo '${environmentShell}'
        echo Shell setup complete!
        '';
      };
      apps."${system}" = {
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
    };
  }
