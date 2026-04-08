{
  description = "ijohanne's NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Vim/Neovim plugins
    nvim-tree-docs = { url = "github:nvim-treesitter/nvim-tree-docs/5db023d783da1e55339e5e25caaf72a59597e626"; flake = false; };

    # Fish plugins
    oh-my-fish-plugin-foreign-env = { url = "github:oh-my-fish/plugin-foreign-env/dddd9213272a0ab848d474d0cbde12ad034e65bc"; flake = false; };
    oh-my-fish-plugin-ssh = { url = "github:oh-my-fish/plugin-ssh/850ec718f23d4182c0fc751adc04e9318e451f21"; flake = false; };

    # Tools
    hexokinase = { url = "github:RRethy/hexokinase/11fc3efc6752b580083ea7891db8216377571b6d"; flake = false; };

    # Prometheus exporters
    hue_exporter = { url = "github:aexel90/hue_exporter"; flake = false; };
    netatmo-exporter = { url = "github:xperimental/netatmo-exporter/b555053621a2e61c4242f7c11e90a093c026b8b3"; flake = false; };
    nftables-exporter = { url = "github:metal-stack/nftables-exporter/v0.4.3"; flake = false; };
    prometheus-ecowitt-exporter = { url = "github:ijohanne/prometheus-ecowitt-exporter"; };
    prometheus-gardena-exporter = { url = "github:ijohanne/prometheus-gardena-exporter"; };
    prometheus-gpsd-exporter = { url = "github:ijohanne/prometheus-gpsd-exporter"; };
    prometheus-tplink-p110-exporter = { url = "github:ijohanne/prometheus-tplink-p110-exporter"; };
    ts3exporter = { url = "github:hikhvar/ts3exporter/a38c91b397a67f3675af4985ecd2f8c0e5354a7c"; flake = false; };

    pg-exporter = { url = "github:pgsty/pg_exporter/v1.2.0"; flake = false; };

    # CLI tools
    agent-skills-cli = { url = "github:Karanjot786/agent-skills-cli/9504db2a3d62284e209186a7881457633209a890"; flake = false; };

    # Container registry
    zot = { url = "github:project-zot/zot/v2.1.15"; flake = false; };

    # Other packages
    hrafnsyn = {
      url = "github:ijohanne/hrafnsyn";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    multicast-relay = { url = "github:alsmith/multicast-relay/2c0e4c743127066388de2c5fd6a7eed676d9b523"; flake = false; };
    nixpkgs-firefox-addons = { url = "github:ijohanne/nixpkgs-firefox-addons/215fb67222ad97261efd7a8bef65a2154586b335"; flake = false; };
    sddm-chili = { url = "github:MarianArlt/sddm-chili/6516d50176c3b34df29003726ef9708813d06271"; flake = false; };
    sddm-sugar-dark = { url = "github:MarianArlt/sddm-sugar-dark/9fc363cc3f6b3f70df948c88cbe26989386ee20d"; flake = false; };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      packSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      devSystems = packSystems;
      forPackSystems = f: nixpkgs.lib.genAttrs packSystems (system: f system);
      forDevSystems = f: nixpkgs.lib.genAttrs devSystems (system: f system);
      sources = builtins.removeAttrs inputs [ "self" "nixpkgs" "hrafnsyn" "prometheus-ecowitt-exporter" "prometheus-gardena-exporter" "prometheus-gpsd-exporter" "prometheus-tplink-p110-exporter" ];
    in
    {
      legacyPackages = forPackSystems (system:
        (import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
          inherit sources;
        }) // {
          hrafnsyn = inputs.hrafnsyn.packages.${system}.default;
          hrafnsyn-aircraft-db = inputs.hrafnsyn.packages.${system}.aircraftDb;
          prometheus-ecowitt-exporter = inputs.prometheus-ecowitt-exporter.packages.${system}.default;
          prometheus-gardena-exporter = inputs.prometheus-gardena-exporter.packages.${system}.default;
          prometheus-gpsd-exporter = inputs.prometheus-gpsd-exporter.packages.${system}.default;
          prometheus-tplink-p110-exporter = inputs.prometheus-tplink-p110-exporter.packages.${system}.default;
        });

      devShells = forDevSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            name = "nur-packages-shell";
            buildInputs = with pkgs; [
              nixpkgs-fmt
              shellcheck
              shfmt
              git
            ];
          };
        });

      overlays.default = import ./overlay.nix;

      nixosModules = (import ./modules) // {
        hrafnsyn = inputs.hrafnsyn.nixosModules.default;
        multicast-relay = import ./modules/multicast-relay self;
        prometheus-gardena-exporter = inputs.prometheus-gardena-exporter.nixosModules.default;
        prometheus-gpsd-exporter = inputs.prometheus-gpsd-exporter.nixosModules.default;
        prometheus-hue-exporter = import ./modules/prometheus-hue-exporter self;
        prometheus-nftables-exporter = import ./modules/prometheus-nftables-exporter self;
        prometheus-ecowitt-exporter = inputs.prometheus-ecowitt-exporter.nixosModules.default;
        prometheus-tplink-p110-exporter = inputs.prometheus-tplink-p110-exporter.nixosModules.default;
        pg-exporter = import ./modules/pg-exporter self;
        zot = import ./modules/zot self;
      };
    };
}
