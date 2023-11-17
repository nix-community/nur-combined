# shellcheck shell=bash

firefoxExtensionBuildHoook() {
  echo "Executing firefoxExtensionBuildHoook"

  runHook preBuild

  # shellcheck disable=2086
  if ! NO_UPDATE_NOTIFIER=true @webExt@ build --filename=addon.xpi $webextBuildFlags; then
    echo
    echo 'ERROR: `web-ext build` failed'
    echo

    exit 1
  fi

  runHook postBuild

  echo "Finished firefoxExtensionBuildHoook"
}

if [ -z "${buildPhase-}" ]; then
  buildPhase=firefoxExtensionBuildHoook
fi
