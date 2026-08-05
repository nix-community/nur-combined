{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "realise-sources";
    runtimeInputs = [pkgs.nix];
    text = ''
      # crane parses Cargo.lock and crawls package sources at evaluation
      # time, which realises the source FODs' context. On a fresh store a
      # just-bumped source is neither substitutable nor instantiated as a
      # .drv, so evaluation fails with "path '...-source.drv' is not valid".
      # Fetching the sources up front (small downloads) avoids it.
      # Must be run from the repository root.
      nix build --impure --no-link --print-build-logs --expr '
        let
          flake = builtins.getFlake ("path:" + builtins.getEnv "PWD");
          pkgs = flake.inputs.nixpkgs.legacyPackages.''${builtins.currentSystem};
          sources = pkgs.callPackage ./_sources/generated.nix {};
        in
          map (source: source.src) (
            builtins.filter (source: builtins.isAttrs source && source ? src)
              (builtins.attrValues sources)
          )
      '
    '';
  };
in {
  realise-sources = {
    type = "app";
    program = "${script}/bin/realise-sources";
    meta.description = "Realise all nvfetcher source FODs (required before crane evaluations on a fresh store)";
  };
}
