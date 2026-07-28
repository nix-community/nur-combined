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
    let
      # bash = pkgs.bash.__spliced.buildBuild or pkgs.bash;
      bash = pkgs.bashNonInteractive;
    in
    assert !vaculib.isPrefixOf "-" cmd;
    derivation (
      {
        builder = lib.getExe bash;
        args = [
          "-c"
          cmd
        ];
        inherit (bash) system;
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
