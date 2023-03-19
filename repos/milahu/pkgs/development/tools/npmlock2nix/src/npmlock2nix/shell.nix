let
  pkgs = import ./nix { };

  test-runner = pkgs.writeScriptBin "test-runner" ''
    find . -type f | ${pkgs.entr}/bin/entr -c nix-build -A tests --show-trace
  '';

  pre-commit-hooks = pkgs.nix-pre-commit-hooks.run {
    src = ./.;
    tools = {
      nixpkgs-fmt = pkgs.nixpkgs-fmt;
    };
    hooks = {
      nixpkgs-fmt.enable = true;
    };
  };

in
pkgs.mkShell {
  buildInputs = [ test-runner pkgs.nodejs pkgs.smoke pkgs.niv pkgs.nixpkgs-fmt ];
  inherit (pre-commit-hooks) shellHook;
}
