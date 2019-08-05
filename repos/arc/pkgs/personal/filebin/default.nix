{
  substituteShellScriptBin,
  coreutils, awscli, curl ? null
}:
substituteShellScriptBin "filebin" ./filebin.sh {
  depsRuntimePath = [coreutils awscli curl];
}
