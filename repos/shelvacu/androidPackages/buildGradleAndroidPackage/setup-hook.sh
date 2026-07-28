addGradleAndroidArgs() {
  if [[ -z ${ANDROID_HOME:-} ]]; then
    echo "ERR: ANDROID_HOME not set" >&2
    exit 1
  fi

  declare -a build_tools_dirs=()
  for d in "$ANDROID_HOME/build-tools/"*; do
    if [[ -d $d ]]; then
      build_tools_dirs+=("$d")
    fi
  done

  if (("${#build_tools_dirs[@]}" == 0)); then
    echo "ERR: couldn't find build-tools dir" >&2
    exit 1
  fi

  declare build_tools_dir="${build_tools_dirs[-1]}"

  if (("${#build_tools_dirs[@]}" > 1)); then
    declare -p build_tools_dirs
    echo "WARN: more than one build-tools dir, picking $build_tools_dir" >&2
  fi

  gradleFlagsArray+=(
    "-Dorg.gradle.project.android.aapt2FromMavenOverride=$build_tools_dir/aapt2"
  )
}

addGradleAndroidArgs
