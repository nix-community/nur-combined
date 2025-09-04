{ pkgs }:

with pkgs.lib;
{
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  fromJSON5File =
    json5File:
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "parsed.json" {
          nativeBuildInputs = [ pkgs.python3Packages.json5 ];
        } "pyjson5 --as-json ${json5File} > $out"
      )
    );
}
