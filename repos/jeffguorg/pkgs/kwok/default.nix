{ pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ../../flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import "${fetchTree gomod2nix.locked}/overlay.nix")
      ];
    }
  )
, buildGoModule ? pkgs.buildGoModule
, sources ? pkgs.callPackage ../../_sources/generated.nix {}
, ...
}:
let
  src = sources.kwok;
in
buildGoModule {
  inherit (src) pname version;

  vendorHash = "sha256-UNso+e/zYah0jApHZgWnQ3cUSV44HsMqPy4q4JMCyiA=";
  #goPackagePath = "sigs.k8s.io/kwok";

  subPackages = [
    "cmd/kwok"
    "cmd/kwokctl"
  ];

  #modules = ./gomod2nix.toml;

  src = src.src;
}
