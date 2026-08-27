# Merge declarative Nix module settings into a service's writable runtime config file.
{pkgs}: {
  mkMergeConfig = {
    name,
    format,
  }: let
    merger =
      pkgs.writers.writePython3 "${name}-merge" {
        libraries =
          if format == "yaml"
          then [pkgs.python3Packages.pyyaml]
          else [pkgs.python3Packages.tomli-w];
        flakeIgnore = [
          "E501"
          "W503"
        ];
      }
      (builtins.readFile ./merge.py);
  in
    # Fix the serialization format here so call sites never repeat it.
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        exec ${merger} --format ${format} "$@"
      '';
    };
}
