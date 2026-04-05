renpyBuildHook() {
  echo "Executing renpyBuildHook"
  runHook preBuild

  renpy --compile --compile-python --keep-orphan-rpyc ${renpyCompileFlags[@]} . compile

  runHook postBuild
  echo "Finished renpyBuildHook"
}

if [[ -z "${dontRenpyBuild-}" ]] && [[ -z "${buildPhase-}" ]]; then
  buildPhase=renpyBuildHook
fi
