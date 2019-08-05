{ runCommand, wrapShellScriptBin, callPackage, lib, coreutils, git }:
let
  hook-chain = callPackage (wrapShellScriptBin "hook-chain.sh" ./hook-chain.sh) {
    depsRuntimePath = [coreutils git];
  };
  git-hooks = [
    "pre-applypatch" "pre-commit" "pre-push" "pre-rebase"
    "prepare-commit-msg" "update"
    "commit-msg"
    "applypath-msg"
    "post-update"
  ];
in
# provides a git templateDir that calls multiple hooks from .git/hooks/$HOOK.d/*
runCommand "hook-chain" {
  hookChainHooks = lib.concatStringsSep " " git-hooks;
  hookChainExec = hook-chain.exec;
} ''
  install -d $out/hooks
  for f in $hookChainHooks; do
    ln -s $hookChainExec $out/hooks/$f
    install -d $out/hooks/$f.d
  done
''
