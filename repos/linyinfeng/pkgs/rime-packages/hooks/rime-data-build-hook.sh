rime_data=()

function addRimeData {
  if [ -d "$1/share/rime-data" ]; then
    echo "found rime-data $1"
    rime_data+=("$1")
  fi
}
addEnvHooks "$hostOffset" addRimeData

function rimeDataBuildPreBuildHook {
  echo "Executing rimeDataBuildPreBuildHook"
  mkdir "rime_data_deps"
  local processed=""
  for data in "${rime_data[@]}"; do
    case $processed in
    *\ $data\ *)
      break
      ;;
    esac
    processed="$processed $data "

    echo "linking RIME dependency '$data'..."
    cp --recursive --verbose "$data/share/rime-data/." rime_data_deps/
  done
  echo "Finished executing rimeDataBuildPreBuildHook"
}

function rimeDataBuildHook {
  echo "Executing rimeDataBuildHook"
  runHook preBuild

  for schema_file in *.schema.yaml; do
    rime_deployer --compile "$schema_file" . rime_data_deps
  done

  runHook postBuild
  echo "Finished executing rimeDataBuildHook"
}

function rimeDataBuildPostBuildHook {
  echo "Executing rimeDataBuildPostBuildHook"

  if [ -d rime_data_deps/build ]; then
    for compiled_file in $(ls rime_data_deps/build); do
      if [ -f "build/$compiled_file" ]; then
        echo "delete 'build/$compiled_file'..."
        rm "build/$compiled_file"
      fi
    done
  fi

  echo "Finished executing rimeDataBuildPostBuildHook"
}

if [ -z "${dontRimeDataBuild-}" ]; then
  preBuildHooks+=(rimeDataBuildPreBuildHook)
  postBuildHooks+=(rimeDataBuildPostBuildHook)
fi
if [ -z "${dontRimeDataBuild-}" ] && [ -z "${buildPhase-}" ]; then
  buildPhase=rimeDataBuildHook
fi
