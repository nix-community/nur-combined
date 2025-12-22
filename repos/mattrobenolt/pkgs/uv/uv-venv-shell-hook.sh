uvVenvShellHook() {
  echo "Executing uvVenvShellHook"
  runHook preShellHook

  if [ -d "${venvDir}" ]; then
    echo "Skipping venv creation, '${venvDir}' already exists"
    # shellcheck disable=SC1090
    source "${venvDir}/bin/activate"
  else
    echo "Creating new uv venv environment in path: '${venvDir}'"
    "@uv@" venv "${venvDir}"
    # shellcheck disable=SC1090
    source "${venvDir}/bin/activate"
    runHook postVenvCreation
  fi

  runHook postShellHook
  echo "Finished executing uvVenvShellHook"
}

if [ -z "${dontUseVenvShellHook:-}" ] && [ -z "${shellHook-}" ]; then
  echo "Using uvVenvShellHook"
  if [ -z "${venvDir-}" ]; then
    venvDir=".venv"
  fi
  shellHook=uvVenvShellHook
fi
