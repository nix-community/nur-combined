{
  substituteShellScriptBin, lib,
  coreutils, awscli2, curl ? null
}:
substituteShellScriptBin "filebin" ./filebin.sh {
  depsRuntimePath = [coreutils awscli2 curl];
}
