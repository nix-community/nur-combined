{pkgs}: let
  system = pkgs.stdenv.hostPlatform.system;
  script = pkgs.writeShellApplication {
    name = "update-hashes";
    runtimeInputs = [
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.nix
      pkgs.nix-update
    ];
    text = ''
      files="$(
        grep --recursive --files-with-matches --include='*.nix' \
          --extended-regexp '[[:alnum:]_]+Hash = "sha256-' pkgs || true
      )"
      if [[ -n "$files" ]]; then
        while IFS= read -r file; do
          attr="$(basename "$(dirname "$file")")"
          if nix eval ".#packages.${system}.$attr.pname" >/dev/null 2>&1; then
            echo "Updating hashes for $attr"
            nix-update --flake "$attr" --version skip --override-filename "$file"
          else
            echo "Skipping $attr: no matching flake package" >&2
          fi
        done <<<"$files"
      fi
    '';
  };
in {
  update-hashes = {
    type = "app";
    program = "${script}/bin/update-hashes";
    meta.description = "Refresh vendored dependency hashes with nix-update";
  };
}
