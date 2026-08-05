{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "realise-sources";
    runtimeInputs = [pkgs.nix];
    # The nix expressions are intentionally single-quoted so the shell does
    # not expand them.
    excludeShellChecks = ["SC2016"];
    text = ''
      # crane parses Cargo.lock and crawls package sources at evaluation
      # time, which realises the source FODs' context. On a fresh store a
      # just-bumped source is neither substitutable nor instantiated as a
      # .drv, so evaluation fails with "path '...-source.drv' is not valid".
      # Must be run from the repository root.

      # Fetch the source FOD outputs. They are platform-independent, so
      # fetching them for the host system makes them available to every
      # supported system.
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

      # Evaluating the package sets of *other* systems (e.g. via
      # `nix flake check --all-systems`) references each system's own
      # source .drv in the eval-time context, and realising that context
      # requires the .drv files to be valid in the store even though the
      # outputs are shared. Instantiate (but do not build) the source
      # derivations for every supported system.
      nix eval --impure --raw --expr '
        let
          flake = builtins.getFlake ("path:" + builtins.getEnv "PWD");
          systems = import ./internal/systems.nix;
          sourcesFor = system:
            flake.inputs.nixpkgs.legacyPackages.''${system}.callPackage ./_sources/generated.nix {};
        in
          builtins.concatStringsSep "\n" (
            map (source: source.src.drvPath) (
              builtins.concatMap (
                system:
                  builtins.filter (source: builtins.isAttrs source && source ? src)
                  (builtins.attrValues (sourcesFor system))
              )
              systems
            )
          )
      ' >/dev/null
    '';
  };
in {
  realise-sources = {
    type = "app";
    program = "${script}/bin/realise-sources";
    meta.description = "Realise all nvfetcher source FODs (required before crane evaluations on a fresh store)";
  };
}
