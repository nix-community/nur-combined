{
  flake,
  system,
  pkgs,
}:
let
  nur-meta = pkgs.callPackage ./meta-generator.nix { inherit flake system; };
  nur-readme-generator = pkgs.callPackage ./readme-generator.nix { };
in
pkgs.writeShellApplication {
  name = "nur-readme-update";

  runtimeInputs = [
    nur-readme-generator
    pkgs.gitMinimal
  ];

  text = ''
    ROOT="$(git rev-parse --show-toplevel)"
    export ROOT

    nur-readme-generator --meta "${nur-meta}" --readme "''${ROOT}/README.md" "$@"
  '';
}
