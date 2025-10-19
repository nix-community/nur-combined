{ pkgs, repo }:
with pkgs.lib;
rec {
  fromYAML = yamlStr: fromYAMLPath (builtins.toFile "fromYAML.yaml" yamlStr);
  fromYAMLPath =
    yamlPath:
    let
      jsonPath = pkgs.runCommand "fromYAML.json" { inherit yamlPath; } ''
        ${repo.json-yaml}/bin/yaml-json "$yamlPath" > $out
      '';
    in
    builtins.fromJSON (builtins.readFile jsonPath);

  toYAML = expr: builtins.readFile (toYAMLPath expr);
  toYAMLPath =
    expr:
    let
      jsonPath = builtins.toFile "toYAML.json" (builtins.toJSON expr);
    in
    pkgs.runCommand "toYAML.yaml" { inherit jsonPath; } ''
      ${repo.json-yaml}/bin/json-yaml "$jsonPath" > $out
    '';
}
