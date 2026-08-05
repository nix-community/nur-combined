{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "update-packages";
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
  update = {
    type = "app";
    program = "${script}/bin/update-packages";
    meta.description = "Update package sources with nvfetcher";
  };
}
