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

      nix flake update
      nvfetcher "''${key_flags[@]}" -c nvfetcher.toml -o _sources "$@"
    '';
  };
in {
  update-sources = {
    type = "app";
    program = "${script}/bin/update-sources";
    meta.description = "Update flake inputs and nvfetcher package sources";
  };
}
