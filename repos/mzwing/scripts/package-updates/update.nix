{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "update-packages";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.git
      pkgs.nix
      pkgs.nvfetcher
      pkgs.python3
    ];
    text = ''
      export LANG=en_US.UTF-8
      key_flags=()
      [[ -f "$HOME/Secrets/nvfetcher.toml" ]] && key_flags+=(-k "$HOME/Secrets/nvfetcher.toml")
      [[ -f secrets.toml ]] && key_flags+=(-k secrets.toml)
      export PYTHONPATH="${pkgs.python3Packages.packaging}/lib/python${pkgs.python3.pythonVersion}/site-packages:''${PYTHONPATH:-}"

      nix flake update
      nvfetcher "''${key_flags[@]}" -c nvfetcher.toml -o _sources "$@"

      while IFS= read -r update_script; do
        echo "Executing $update_script"
        chmod +x "$update_script"
        "$update_script"
      done < <(find pkgs -type f -name 'update.*' -print | sort)
    '';
  };
in {
  update = {
    type = "app";
    program = "${script}/bin/update-packages";
    meta.description = "Update package sources with nvfetcher";
  };
}
