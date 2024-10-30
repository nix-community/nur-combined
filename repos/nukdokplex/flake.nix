{
  description = "NukDokPlex's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = { self, flake-utils, ... }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import self.inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        checks.pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
          };
        };
        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
        legacyPackages = import ./default.nix { inherit pkgs; };
        packages = self.inputs.nixpkgs.lib.filterAttrs (_: v: self.inputs.nixpkgs.lib.isDerivation v) self.legacyPackages.${system};
      }
    );
}
