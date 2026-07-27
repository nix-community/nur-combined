# shellcheck disable=SC2154
juceCmakeInstallPhase() {
  for f in *_artefacts/Release/Standalone/*; do
    mkdir -p "$out"/bin
    cp "$f" "$out"/bin
  done

  for f in *_artefacts/Release/CLAP/*; do
    mkdir -p "$out"/lib/clap
    cp "$f" "$out"/lib/clap
  done

  for f in *_artefacts/Release/LV2/*; do
    mkdir -p "$out"/lib/lv2
    cp -r "$f" "$out"/lib/lv2
  done

  for f in *_artefacts/Release/VST3/*; do
    mkdir -p "$out"/lib/vst3
    cp -r "$f" "$out"/lib/vst3
  done
}

juceCmakePostFixup() {
  for f in "$out"/bin/*; do
    patchelf "$f" --add-rpath @rpath@
  done
}

# shellcheck disable=SC2034
if [ -z "${dontUseJuceInstall-}" ] && [ -z "${installPhase-}" ]; then
  installPhase=juceCmakeInstallPhase
fi

postFixupHooks+=(juceCmakePostFixup)

cmakeFlagsArray+=(
  '-DCMAKE_CXX_FLAGS="-fuse-ld=mold"' # juce really doesn't like gcc it seems
  "-DCOPY_PLUGIN_AFTER_BUILD=FALSE"
  "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
)
