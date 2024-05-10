{ config
, lib
, ...
}:

with lib;
let
  cfg = config.profile.predicates;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.predicates = {
    unfreePackages = mkOption {
      default = [ ];
      type = types.listOf types.str;
      description = ''
        List of unfree packages (in the predicate format) to allow
      '';
    };
  };

  config = (mkMerge [
    { nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.unfreePackages; }
  ]);
}

