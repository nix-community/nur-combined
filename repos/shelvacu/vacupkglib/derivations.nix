{
  lib,
  pkgs,
  vaculib,
  ...
}:
rec {
  runCommandBare =
    {
      cmd,
      local ? true,
      ...
    }@args:
    assert !vaculib.isPrefixOf "-" cmd;
    derivation (
      {
        builder = lib.getExe pkgs.bash;
        args = [
          "-c"
          cmd
        ];
        system = pkgs.stdenv.buildPlatform.system;
      }
      // (lib.optionalAttrs local { preferLocalBuild = true; })
      // (lib.removeAttrs args [
        "cmd"
        "local"
      ])
    );

  outputOf =
    {
      removeNewline ? true,
      ...
    }@args:
    let
      passThruArgs = lib.removeAttrs args [ "removeNewline" ];
      res = builtins.readFile (runCommandBare passThruArgs);
      noNewline = lib.removeSuffix "\n" res;
    in
    if removeNewline then noNewline else res;
}
