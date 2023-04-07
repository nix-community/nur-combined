{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        inherit (pkgs) lib;
        packages = import ./. { inherit pkgs; };
      in
      {
        inherit packages;
        checks.build =
          pkgs.linkFarmFromDrvs "amesgen-nur-packages" (lib.attrValues packages);
        devShells.default =
          let
            nvfetcherCfg = (pkgs.formats.toml { }).generate "nvfetcher.toml"
              (import ./pkgs/nvfetcher.nix pkgs);
            nvfetcher = pkgs.writeShellScriptBin "nvfetcher" ''
              ${pkgs.nvfetcher}/bin/nvfetcher \
                -o pkgs/_sources \
                -c <(sed -e 's/"\(.*\)" =/\1 =/g' ${nvfetcherCfg}) \
                "$@"
            '';
          in
          pkgs.mkShell {
            buildInputs = [ nvfetcher ];
          };
      }
    );
}
