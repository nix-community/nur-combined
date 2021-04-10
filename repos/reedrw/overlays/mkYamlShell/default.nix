{ lib
, runCommand
, mkShell
, remarshal
, pkgs
}:

let

  fromYaml = yamlFile:
    let
      jsonFile = runCommand "yaml-str-to-json"
        {
          nativeBuildInputs = [ remarshal ];
        } ''
        yaml2json "${yamlFile}" "$out"
      '';
    in
    builtins.fromJSON (builtins.readFile "${jsonFile}");

  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
    in
    builtins.foldl' (sum: attr: sum.${attr}) pkgs attrs;

  # transform the env vars into bash instructions
  envToBash = env:
    builtins.concatStringsSep "\n"
      (lib.mapAttrsToList
        (k: v: "export ${k}=${lib.escapeShellArg (toString v)}")
        env
      )
  ;

  mkYamlShell = shellFile:
    let
      shell = fromYaml shellFile;
      name = "${shell.name}";
      packages = map resolveKey (shell.packages or [ ]);
      shellHook = ''
        ${envToBash shell.env}
        ${shell.run}
      '';

      out = mkShell {
        inherit
          name
          shellHook
          ;
        buildInputs = packages;
      };
    in
    out;

in
{
  inherit
    fromYaml
    mkYamlShell
    ;

  __functor = _: mkYamlShell;

}
