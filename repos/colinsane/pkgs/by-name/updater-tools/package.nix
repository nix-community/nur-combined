{
  lib,
  newScope,
  writeScriptBin,
}:
lib.makeScope newScope (self: {
  # The actual shell command (argv) which can run the provided updateScript, after an environment has been configured for the updater:
  updateScriptToArgv = updateScript:
    if builtins.isList updateScript then
      updateScript
    else if updateScript ? command then
      map toString updateScript.command
    else if (updateScript.meta or {}) ? mainProgram then
      # raw derivation like `writeShellScriptBin`
      [ (lib.getExe updateScript) ]
    else if builtins.isPath updateScript then
      # in-tree update script like `updateScript = ./update.sh`
      [ updateScript ]
    else
      null
  ;

  updateArgvForPkg = pkg:
    if pkg ? updateScript then
      self.updateScriptToArgv pkg.updateScript
    else
      null
  ;

  updateScriptToShellcode = updateScript:
    lib.escapeShellArgs (self.updateScriptToArgv updateScript);

  # try the first updateScript, if that one fails then try the next, and so on.
  # exits once the first updateScript succeeds.
  tryInSequence = updateScripts:
  let
    shellCode = lib.concatMapStringsSep " || " self.updateScriptToShellcode updateScripts;
  in
  {
    command = [(
      lib.getExe (writeScriptBin "try-in-sequence" shellCode)
    )];
  };

  applyAll = updateScripts:
  let
    shellCode = lib.concatMapStringsSep " ; " (s: "( ${self.updateScriptToShellcode s} )") updateScripts;
  in
  {
    command = [(
      lib.getExe (writeScriptBin "apply-all" shellCode)
    )];
  };
})
