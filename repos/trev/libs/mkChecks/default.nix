{
  lib,
  mkCheck,
  callChecks,
}:

let
  mkChecks =
    prefix: checks:
    builtins.zipAttrsWith
      (
        name: values:
        if builtins.length values > 1 then
          throw "mkChecks: more than one check is named '${name}'"
        else
          builtins.head values
      )
      (
        lib.mapAttrsToList (
          name: check:
          let
            fullName = prefix + name;
            # a path is shorthand for a group that needs no extra arguments
            group = if builtins.isPath check then callChecks check { } else check;
          in
          if group._type or null == "checks" then
            mkChecks "${fullName}-" group.checks
          else
            { ${fullName} = mkCheck fullName check; }
        ) checks
      );
in
mkChecks ""
