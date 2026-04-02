#!/usr/bin/env bash
set -euo pipefail

SYSTEM="${SYSTEM:-x86_64-linux}"
# BEGIN opencode-vim updater block
OPENCODE_RELEASE_OWNER="leohenon"
OPENCODE_RELEASE_REPO="opencode"
OPENCODE_HASHES_FILE="pkgs/opencode/hashes.json"
# END opencode-vim updater block
declare -a TEMP_BACKUP_FILES=()

cleanup_temp_backups() {
  local backup_file

  for backup_file in "${TEMP_BACKUP_FILES[@]}"; do
    rm -f "${backup_file}" || true
  done

  TEMP_BACKUP_FILES=()
}

trap cleanup_temp_backups EXIT
trap 'cleanup_temp_backups; exit 130' INT TERM

list_derivations() {
  local source_kind=$1
  local attrset=$2
  local apply_expr='pkgs: builtins.concatStringsSep "\n" (builtins.filter (name: let v = builtins.getAttr name pkgs; in builtins.isAttrs v && v ? type && v.type == "derivation") (builtins.attrNames pkgs))'

  if [ "${source_kind}" = "flake" ]; then
    nix eval --raw ".#${attrset}" --apply "${apply_expr}"
  else
    nix eval --raw --file default.nix "${attrset}" --apply "${apply_expr}"
  fi
}

escape_nix_string() {
  local value=$1

  value=${value//\\/\\\\}
  value=${value//\"/\\\"}

  printf '%s' "${value}"
}

read_package_version() {
  local source_kind=$1
  local attrset=$2
  local attr=$3
  local escaped_attr
  local version

  escaped_attr=$(escape_nix_string "${attr}")
  if [ "${source_kind}" = "flake" ]; then
    version=$(nix eval --raw ".#${attrset}" --apply "pkgs: let pkg = builtins.getAttr \"${escaped_attr}\" pkgs; in if builtins.isAttrs pkg && pkg ? version then pkg.version else \"\"" 2>/dev/null || true)
  else
    version=$(nix eval --raw --file default.nix "${attrset}" --apply "pkgs: let pkg = builtins.getAttr \"${escaped_attr}\" pkgs; in if builtins.isAttrs pkg && pkg ? version then pkg.version else \"\"" 2>/dev/null || true)
  fi

  printf '%s' "${version}"
}

pick_version_mode() {
  local version=$1

  if [[ "${version}" =~ (^|[-._])unstable($|[-._0-9]) ]] || [[ "${version}" =~ (^|[-._])git($|[-._0-9]) ]]; then
    printf '%s' "branch"
  else
    printf '%s' "stable"
  fi
}

version_mode_for() {
  local source_kind=$1
  local attrset=$2
  local attr=$3
  local version

  version=$(read_package_version "${source_kind}" "${attrset}" "${attr}")
  pick_version_mode "${version}"
}

attribute_file_path_from_file() {
  local attrset=$1
  local attr=$2
  local escaped_attr
  local position
  local file_path
  local root_dir
  local candidate

  escaped_attr=$(escape_nix_string "${attr}")
  position=$(nix eval --raw --file default.nix "${attrset}" --apply "pkgs: let pkg = builtins.getAttr \"${escaped_attr}\" pkgs; in if builtins.isAttrs pkg && pkg ? meta && pkg.meta ? position then pkg.meta.position else \"\"" 2>/dev/null || true)

  if [ -z "${position}" ]; then
    return 1
  fi

  file_path=${position%%:*}
  if [ -z "${file_path}" ] || [ ! -f "${file_path}" ]; then
    return 1
  fi

  root_dir=$(dirname "${file_path}")

  candidate="${root_dir}/${attr}/default.nix"
  if [ -f "${candidate}" ]; then
    printf '%s' "${candidate}"
    return 0
  fi

  candidate="${root_dir}/${attr}.nix"
  if [ -f "${candidate}" ]; then
    printf '%s' "${candidate}"
    return 0
  fi

  printf '%s' "${file_path}"
}

normalize_unstable_version_format() {
  local file_path=$1
  local previous_version=$2
  local current_version=$3
  local prefix="0"
  local date_part
  local escaped_prefix

  if [[ ! "${current_version}" =~ ^([A-Za-z0-9.+-]+-)?unstable-([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
    return 0
  fi

  date_part=${BASH_REMATCH[2]}

  if [[ "${previous_version}" =~ ^([A-Za-z0-9.+-]+)-unstable-[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    prefix=${BASH_REMATCH[1]}
  fi

  escaped_prefix=$(printf '%s' "${prefix}" | sed -e 's/[&|\\]/\\&/g')

  sed -E -i "0,/version = \"([^\"]+-)?unstable-([0-9]{4}-[0-9]{2}-[0-9]{2})\";/s|version = \"([^\"]+-)?unstable-([0-9]{4}-[0-9]{2}-[0-9]{2})\";|version = \"${escaped_prefix}-unstable-${date_part}\";|" "${file_path}"
}

version_is_older() {
  local candidate=$1
  local baseline=$2
  local escaped_candidate
  local escaped_baseline
  local result

  escaped_candidate=$(escape_nix_string "${candidate}")
  escaped_baseline=$(escape_nix_string "${baseline}")
  result=$(nix eval --raw --expr "if builtins.compareVersions \"${escaped_candidate}\" \"${escaped_baseline}\" < 0 then \"1\" else \"0\"" 2>/dev/null || printf '0')

  [ "${result}" = "1" ]
}

should_block_downgrade() {
  local before_version=$1
  local after_version=$2

  if [ -z "${before_version}" ] || [ -z "${after_version}" ]; then
    return 1
  fi

  if [[ "${before_version}" =~ ^v?[0-9] ]] && [[ "${after_version}" =~ ^v?[0-9] ]]; then
    return 0
  fi

  return 1
}

run_updates() {
  local attrset=$1
  local -a attrs=()

  mapfile -t attrs < <(list_derivations "flake" "${attrset}")

  for attr in "${attrs[@]}"; do
    local attr_path="${attrset}.${attr}"
    local version_mode

    version_mode=$(version_mode_for "flake" "${attrset}" "${attr}")
    run_nix_update "flake" "${version_mode}" "${attr_path}" || true
  done
}

list_update_attrsets_from_file() {
  nix eval --raw --file default.nix --apply '
    f:
    let
      attrs = f {};
      isDerivation = v: builtins.isAttrs v && v ? type && v.type == "derivation";
      hasDerivationMembers = set:
        builtins.any (name: isDerivation (builtins.getAttr name set)) (builtins.attrNames set);
    in
      builtins.concatStringsSep "\n"
      (builtins.filter
        (name:
          let v = builtins.getAttr name attrs;
          in builtins.isAttrs v && !isDerivation v && hasDerivationMembers v)
        (builtins.attrNames attrs))'
}

list_update_attrsets_from_flake() {
  if nix eval --raw ".#packages.${SYSTEM}" --apply 'pkgs: ""' >/dev/null 2>&1; then
    printf '%s\n' "packages.${SYSTEM}"
  fi
}

run_nix_update() {
  local source_kind=$1
  local version_mode=$2
  local attr_path=$3

  if [ "${source_kind}" = "flake" ]; then
    nix run nixpkgs#nix-update -- --flake --use-github-releases --version="${version_mode}" "${attr_path}"
  else
    nix run nixpkgs#nix-update -- -f default.nix --version="${version_mode}" "${attr_path}"
  fi
}

cleanup_backup_file() {
  local backup_file=${1:-}

  if [ -n "${backup_file}" ]; then
    rm -f "${backup_file}" || true
  fi
}

# BEGIN opencode-vim updater block
opencode_vim_asset_for_system() {
  local system=$1

  case "${system}" in
  x86_64-linux)
    printf '%s' 'ocv-linux-x64.tar.gz'
    ;;
  aarch64-linux)
    printf '%s' 'ocv-linux-arm64.tar.gz'
    ;;
  x86_64-darwin)
    printf '%s' 'ocv-darwin-x64.zip'
    ;;
  aarch64-darwin)
    printf '%s' 'ocv-darwin-arm64.zip'
    ;;
  *)
    return 1
    ;;
  esac
}

read_opencode_vim_hashes_version() {
  nix shell nixpkgs#jq --command jq -r '.version' "${OPENCODE_HASHES_FILE}"
}

read_latest_opencode_vim_release_tag() {
  nix shell nixpkgs#curl nixpkgs#jq --command sh -eu -c '
    curl -fsSL "https://api.github.com/repos/'"${OPENCODE_RELEASE_OWNER}"'/'"${OPENCODE_RELEASE_REPO}"'/releases/latest" \
      | jq -r .tag_name
  '
}

prefetch_opencode_vim_asset_hash() {
  local version=$1
  local system=$2
  local asset

  asset=$(opencode_vim_asset_for_system "${system}")
  nix store prefetch-file --json --hash-type sha256 \
    "https://github.com/${OPENCODE_RELEASE_OWNER}/${OPENCODE_RELEASE_REPO}/releases/download/v${version}/${asset}" |
    nix shell nixpkgs#jq --command jq -r '.hash'
}

write_opencode_vim_hashes_json() {
  local version=$1
  local aarch64_darwin_hash=$2
  local x86_64_darwin_hash=$3
  local x86_64_linux_hash=$4
  local aarch64_linux_hash=$5

  # shellcheck disable=SC2016
  nix shell nixpkgs#jq --command jq -n \
    --arg version "${version}" \
    --arg aarch64_darwin_hash "${aarch64_darwin_hash}" \
    --arg x86_64_darwin_hash "${x86_64_darwin_hash}" \
    --arg x86_64_linux_hash "${x86_64_linux_hash}" \
    --arg aarch64_linux_hash "${aarch64_linux_hash}" \
    '{
      version: $version,
      hashes: {
        "aarch64-darwin": $aarch64_darwin_hash,
        "x86_64-darwin": $x86_64_darwin_hash,
        "x86_64-linux": $x86_64_linux_hash,
        "aarch64-linux": $aarch64_linux_hash
      }
    }' >"${OPENCODE_HASHES_FILE}"
}

update_opencode_vim_package() {
  local before_version
  local latest_tag
  local latest_version
  local aarch64_darwin_hash
  local x86_64_darwin_hash
  local x86_64_linux_hash
  local aarch64_linux_hash

  if [ ! -f "${OPENCODE_HASHES_FILE}" ]; then
    return 0
  fi

  before_version=$(read_opencode_vim_hashes_version)
  latest_tag=$(read_latest_opencode_vim_release_tag)
  latest_version=${latest_tag#v}

  if [ -z "${latest_version}" ]; then
    printf 'Failed to determine latest opencode release version\n' >&2
    return 1
  fi

  if should_block_downgrade "${before_version}" "${latest_version}" && version_is_older "${latest_version}" "${before_version}"; then
    printf 'Skipping apparent downgrade for opencode (%s -> %s)\n' "${before_version}" "${latest_version}" >&2
    return 0
  fi

  if [ "${before_version}" = "${latest_version}" ]; then
    printf 'opencode already up to date at %s\n' "${before_version}"
    return 0
  fi

  printf 'Updating opencode from %s to %s\n' "${before_version}" "${latest_version}"

  aarch64_darwin_hash=$(prefetch_opencode_vim_asset_hash "${latest_version}" 'aarch64-darwin')
  x86_64_darwin_hash=$(prefetch_opencode_vim_asset_hash "${latest_version}" 'x86_64-darwin')
  x86_64_linux_hash=$(prefetch_opencode_vim_asset_hash "${latest_version}" 'x86_64-linux')
  aarch64_linux_hash=$(prefetch_opencode_vim_asset_hash "${latest_version}" 'aarch64-linux')

  write_opencode_vim_hashes_json \
    "${latest_version}" \
    "${aarch64_darwin_hash}" \
    "${x86_64_darwin_hash}" \
    "${x86_64_linux_hash}" \
    "${aarch64_linux_hash}"
}
# END opencode-vim updater block

run_updates_from_file() {
  local attrset=$1
  local -a attrs=()

  mapfile -t attrs < <(list_derivations "file" "${attrset}")

  for attr in "${attrs[@]}"; do
    local attr_path="${attrset}.${attr}"
    local version_mode
    local file_path
    local backup_file=""
    local before_version
    local after_version

    before_version=$(read_package_version "file" "${attrset}" "${attr}")
    version_mode=$(version_mode_for "file" "${attrset}" "${attr}")
    file_path=$(attribute_file_path_from_file "${attrset}" "${attr}" || true)

    if [ -n "${file_path}" ] && [ -f "${file_path}" ]; then
      backup_file=$(mktemp)
      TEMP_BACKUP_FILES+=("${backup_file}")
      cp "${file_path}" "${backup_file}"
    fi

    if ! run_nix_update "file" "${version_mode}" "${attr_path}"; then
      cleanup_backup_file "${backup_file}"
      continue
    fi

    after_version=$(read_package_version "file" "${attrset}" "${attr}")
    if [ -n "${file_path}" ] && [ -f "${file_path}" ]; then
      normalize_unstable_version_format "${file_path}" "${before_version}" "${after_version}"
      after_version=$(read_package_version "file" "${attrset}" "${attr}")
    fi

    if [ -n "${backup_file}" ] && should_block_downgrade "${before_version}" "${after_version}" && version_is_older "${after_version}" "${before_version}"; then
      printf 'Reverting apparent downgrade for %s (%s -> %s)\n' "${attr_path}" "${before_version}" "${after_version}" >&2
      cp "${backup_file}" "${file_path}"
    fi

    cleanup_backup_file "${backup_file}"
  done
}

run_discovered_attrsets() {
  local list_fn=$1
  local run_fn=$2
  local -a attrsets=()

  mapfile -t attrsets < <("${list_fn}")
  for attrset in "${attrsets[@]}"; do
    if [ -n "${attrset}" ]; then
      "${run_fn}" "${attrset}"
    fi
  done
}

run_discovered_attrsets list_update_attrsets_from_flake run_updates
run_discovered_attrsets list_update_attrsets_from_file run_updates_from_file
# BEGIN opencode-vim updater block
update_opencode_vim_package
# END opencode-vim updater block
