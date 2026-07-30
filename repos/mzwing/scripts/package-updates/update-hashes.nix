{pkgs}: let
  system = pkgs.stdenv.hostPlatform.system;
  script = pkgs.writeShellApplication {
    name = "update-package-hashes";
    runtimeInputs = [
      pkgs.coreutils
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
      [[ -z "$files" ]] && exit 0

      while IFS= read -r file; do
        attr="$(basename "$(dirname "$file")")"
        if nix eval ".#packages.${system}.$attr.pname" >/dev/null 2>&1; then
          echo "Updating hashes for $attr"
          nix-update --flake "$attr" --version skip --override-filename "$file"
        else
          echo "Skipping $attr: no matching flake package" >&2
        fi
      done <<<"$files"
    '';
  };
in {
  update-hashes = {
    type = "app";
    program = "${script}/bin/update-package-hashes";
    meta.description = "Update package dependency hashes with nix-update";
  };
}
