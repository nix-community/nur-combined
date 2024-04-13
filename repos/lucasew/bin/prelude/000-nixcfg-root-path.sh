
export NIXCFG_ROOT_PATH="$(sd d root)" || export NIXCFG_ROOT_PATH="$(realpath "$(dirname "$(realpath "$BASH_SOURCE")")/../..")"
