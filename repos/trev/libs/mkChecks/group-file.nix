{
  pkgs,
  writeShellScriptBin,
}:
{
  script = {
    packages = [ (writeShellScriptBin "mkchecks-group-file-command" "echo group-file") ];
    script = ''
      test "$(mkchecks-group-file-command)" = group-file
    '';
  };

  derivation = pkgs.runCommand "mkchecks-group-file-derivation" { } "touch $out";
}
