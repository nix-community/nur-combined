# shellcheck shell=bash

firefoxExtensionInstallHook() {
  echo "Executing firefoxExtensionInstallHook"

  runHook preInstall

  dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
  mkdir -p "$dst"
  install -v -m644 "web-ext-artifacts/addon.xpi" "$dst/$addonId.xpi"

  runHook postInstall

  echo "Finished firefoxExtensionInstallHook"
}

if [ -z "${installPhase-}" ]; then
  installPhase=firefoxExtensionInstallHook
fi
