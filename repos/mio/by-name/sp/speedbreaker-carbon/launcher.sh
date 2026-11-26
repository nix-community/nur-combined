#!/usr/bin/env bash
set -euo pipefail

sourceDir="@source@"
builder="@builder@"
stateRoot="${SPEEDBREAKER_CARBON_STATE:-${XDG_DATA_HOME:-$HOME/.local/share}/speedbreaker-carbon/source}"
sourceCopy="$stateRoot/src"
binary="$stateRoot/build/runtime/SpeedBreaker"
discImage="${SPEEDBREAKER_CARBON_ISO:-}"
installAfterBuild=1
rebuild=0
appArgs=()

usage() {
  cat >&2 <<EOF
usage: speedbreaker-carbon [--build-from <disc-image>] [--rebuild] [--no-install] [game options]

The first source build requires your own USA Collector's Edition Xbox 360
disc image. Set SPEEDBREAKER_CARBON_ISO or pass --build-from. The image is
used to generate the translated C++ and is then installed for the runtime.

Otherwise, arguments are passed to the compiled SpeedBreaker: Carbon program,
for example: speedbreaker-carbon --install /path/to/image.iso
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --build-from)
      if (( $# < 2 )); then
        usage
        exit 2
      fi
      discImage="$2"
      shift 2
      ;;
    --rebuild)
      rebuild=1
      shift
      ;;
    --no-install)
      installAfterBuild=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      appArgs+=("$@")
      break
      ;;
    *)
      appArgs+=("$1")
      shift
      ;;
  esac
done

if [[ "$rebuild" == 1 ]] && [[ -z "$discImage" ]]; then
  echo "error: --rebuild requires --build-from or SPEEDBREAKER_CARBON_ISO" >&2
  exit 2
fi

if [[ ! -x "$binary" ]] || [[ "$rebuild" == 1 ]]; then
  if [[ -z "$discImage" ]]; then
    usage
    exit 2
  fi

  install -d "$stateRoot"
  if [[ ! -f "$sourceCopy/.speedbreaker-carbon-source-@version@" ]]; then
    rm -rf "$sourceCopy"
    cp -R "$sourceDir" "$sourceCopy"
    chmod -R u+w "$sourceCopy"
    touch "$sourceCopy/.speedbreaker-carbon-source-@version@"
  fi

  "$builder" "$discImage" "$sourceCopy" "$stateRoot"

  if [[ "$installAfterBuild" == 1 ]]; then
    "$binary" --install "$discImage"
  fi
fi

exec "$binary" "${appArgs[@]}"
