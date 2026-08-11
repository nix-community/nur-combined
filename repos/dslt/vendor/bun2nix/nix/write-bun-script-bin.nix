{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options.perSystem = mkPerSystemOption {
    options.writeBunScriptBin = mkOption {
      description = ''
        Bun $ Shell Script Writer

        Similar to `pkgs.writeScriptBin`, but instead
        of a bash script, creates a
        [bun $ shell](https://bun.com/docs/runtime/shell)
        script.
      '';
      type = types.functionTo types.package;
    };
  };

  config.perSystem =
    { pkgs, ... }:
    {
      writeBunScriptBin =
        {
          name,
          text,
        }:
        pkgs.writeTextFile {
          inherit name;
          text = ''
            #!${pkgs.bun}/bin/bun
            ${text}
          '';
          executable = true;
          destination = "/bin/${name}";
        };
    };
}
