{
  description = "A flake for building my envs";

  inputs.nixpkgs.url = "github:dguibert/nixpkgs/pu";
  inputs.nix.url = "github:dguibert/nix/pu";
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";
  #inputs.nix-ccache.url       = "github:dguibert/nix-ccache/pu";
  #inputs.nix-ccache.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  #inputs.nur_dguibert_envs.url= "github:dguibert/nur-packages/pu?dir=envs";
  inputs.nur_dguibert_envs.url = "git+file:///home/dguibert/nur-packages?dir=envs";
  inputs.nur_dguibert_envs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nur_dguibert_envs.inputs.nix.follows = "nix";
  inputs.nur_dguibert_envs.inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    nix,
    nur_dguibert_envs,
    flake-utils,
    ...
  } @ flakes: let
    nixpkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [
          nix.overlay
          nur_dguibert_envs.overlay
          nur_dguibert_envs.overlays.extra-builtins
          self.overlays.default
        ];
        config.allowUnfree = true;
      };
  in
    (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgsFor system;
    in rec {
      legacyPackages = pkgs;

      devShells.default = pkgs.mkShell {
        name = "env";
        ENVRC = "env";
        buildInputs = with pkgs; [pkgs.nix jq];
        pre-commit-check-shellHook = inputs.self.checks.${system}.pre-commit-check.shellHook;
      };
      checks = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            # TODO readd git annex pre-commit
            git-annex = {
              enable = true;
              name = "git-annex";
              entry = "git annex pre-commit";
            };
            prettier.enable = true;
            trailing-whitespace = {
              enable = true;
              name = "trim trailing whitespace";
              entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/trailing-whitespace-fixer";
              types = ["text"];
              stages = ["commit" "push" "manual"];
            };
            check-merge-conflict = {
              enable = true;
              name = "check for merge conflicts";
              entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/check-merge-conflict";
              types = ["text"];
            };
          };
        };
      };
    }))
    // rec {
      overlays.default = final: prev: {
      };
    };
}
