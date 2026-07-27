{
  description = "Ray's personal NUR repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      repositoryFor =
        system:
        import ./default.nix {
          pkgs = pkgsFor system;
        };
      mkUpdate =
        pkgs:
        pkgs.writeShellApplication {
          name = "update-ab-download-manager";
          runtimeInputs = with pkgs; [
            coreutils
            curl
            jq
            nix
          ];
          text = builtins.readFile ./pkgs/ab-download-manager/update.sh;
        };
    in
    {
      overlays = import ./overlays;
      homeModules = import ./home-modules;

      legacyPackages = forAllSystems repositoryFor;

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) (repositoryFor system)
      );

      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          package = self.packages.${system}.ab-download-manager;
          update = mkUpdate pkgs;
        in
        {
          ab-download-manager-cli = {
            type = "app";
            program = "${package}/bin/ABDownloadManagerCli";
            meta.description = "Run the AB Download Manager command-line client";
          };
          update-ab-download-manager = {
            type = "app";
            program = "${update}/bin/update-ab-download-manager";
            meta.description = "Update AB Download Manager source metadata";
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          package = self.packages.${system}.ab-download-manager;
        in
        {
          ab-download-manager = package;

          ab-download-manager-package-layout = pkgs.runCommand "ab-download-manager-package-layout" { } ''
            test -x ${package}/bin/ABDownloadManager
            test -x ${package}/bin/ABDownloadManagerCli
            test -x ${package}/bin/ABDownloadManagerNativeMessagingHost
            test -f ${package}/share/applications/com.abdownloadmanager.desktop
            test -f ${package}/lib/mozilla/native-messaging-hosts/com.abdownloadmanager.json
            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              actionlint
              jq
              nixfmt-tree
              shellcheck
            ];
          };
        }
      );
    };
}
