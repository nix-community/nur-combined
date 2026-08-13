{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "update-sources";
    runtimeInputs = [
      pkgs.nix
      pkgs.nvfetcher
    ];
    text = ''
      export LANG=en_US.UTF-8
      key_flags=()
      [[ -f "$HOME/Secrets/nvfetcher.toml" ]] && key_flags+=(-k "$HOME/Secrets/nvfetcher.toml")
      [[ -f secrets.toml ]] && key_flags+=(-k secrets.toml)

      nvfetcher "''${key_flags[@]}" -c nvfetcher.toml -o _sources "$@"
    '';
  };
in {
  update-sources = {
    type = "app";
    program = "${script}/bin/update-sources";
    # Flake inputs (nixpkgs) are deliberately NOT updated here: bumping
    # nixpkgs invalidates every derivation and forces a full rebuild, so
    # the update workflow does it on a weekly cadence instead.
    meta.description = "Update nvfetcher package sources";
  };
}
