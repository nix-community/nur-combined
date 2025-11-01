{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.environment;
  makeDrvInfoPath = concatMapStringsSep ":" (p: if isDerivation p then "${p}/info" else p);
in
{
  meta.maintainers = [
    maintainers.wwmoraes or "wwmoraes"
  ];

  options = {
    environment.infoPath = mkOption {
      type = types.listOf (types.either types.path types.str);
      default = [ ];
      example = [ "$HOME/.local/share/info" ];
      description = "The set of paths that are added to INFOPATH.";
      apply = x: if isList x then makeDrvInfoPath x else x;
    };
  };
  config = {
    environment.infoPath = mkMerge [ ];

    environment.variables = {
      INFOPATH = cfg.infoPath;
    };
  };
}
