{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {
    overlays = [
      (_:pkgs: {
        niv = (import sources.niv { }).niv;
        nur = (import sources.NUR
          {
            inherit pkgs;
          }).repos;
      })
    ];
  }
}:
pkgs.mkShell rec {
  pre-commit-check = (import sources.pre-commit-hooks-nix).run {
    src = (import sources.nix-gitignore { }).gitignoreSource ./.;
    hooks = {
      shellcheck.enable = true;
      nix-linter.enable = true;
      nixpkgs-fmt.enable = true;
    };
    excludes = [
      "pkgs/firefox-plugins/generated-addons.nix" # Generated
      "overlay.nix"
      "ci.nix"
    ];
  };
  name = "home-manager-shell";
  buildInputs = with pkgs; [
    niv
    home-manager
    shellcheck
    shfmt
    nixpkgs-fmt
    git
    nur.rycee.firefox-addons-generator
  ];
  shellHook = ''
    export NIX_PATH="nixpkgs=${sources.nixpkgs}"
    export NIXPKGS_PATH=${sources.nixpkgs}
    ${pre-commit-check.shellHook}
  '';
}
