{ rustPlatforms, rust-analyzer, lib }: with lib; let
  mapPlatform = rustPlatform: makeOverridable rustPlatform.mkShell {
    allowBroken = true;
    cargoCommands = [
      "download-arc" "outdated" "deps" "info"
      "bloat" "llvm-lines"
      "with" "watch"
      "release"
      "fmt" "clippy" "expand"
    ];
    rustTools = [
      "rust-analyzer" "rust-src" "gdb"
    ];
  };
in mapAttrs (_: p: mapPlatform p) {
  inherit (rustPlatforms) stable nightly;
} // {
  impure = mapAttrs (_: p: (mapPlatform p).override {
    meta.skip.ci = true;
  }) {
    inherit (rustPlatforms.impure) stable beta nightly;
  };
}
