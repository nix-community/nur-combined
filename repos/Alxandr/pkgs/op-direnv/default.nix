{
  lib,
  writeTextFile,
  _1password-cli,
  shellcheck-minimal,
  ...
}:

writeTextFile {
  name = "op-direnv";
  executable = false;
  destination = "/share/op-direnv/direnvrc";
  allowSubstitutes = true;
  preferLocalBuild = false;

  text = builtins.replaceStrings [ "@op@" ] [ (lib.getExe _1password-cli) ] (
    builtins.readFile ./direnvrc
  );

  checkPhase = ''
    runHook preCheck
    ${lib.getExe shellcheck-minimal} $out/share/op-direnv/direnvrc
    runHook postCheck
  '';

  meta = {
    description = "Direnv hooks for 1Password CLI";
    homepage = "https://github.com/Alxandr/nur/tree/master/pkgs/op-direnv";
    license = lib.licenses.mit;
  };
}
