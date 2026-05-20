#!/usr/bin/env bash
set -euo pipefail

SYSTEM="${SYSTEM:-x86_64-linux}"
UPDATE_TIMEOUT="${UPDATE_TIMEOUT:-10m}"

declare -a TEMP_BACKUP_FILES=()
JQ_BIN=""
CURL_BIN=""
ACTIVE_BACKUP_FILE=""
ACTIVE_FILE_PATH=""

cleanup_temp_backups() {
	local backup_file

	for backup_file in "${TEMP_BACKUP_FILES[@]}"; do
		rm -f "${backup_file}" || true
	done

	TEMP_BACKUP_FILES=()
}

trap cleanup_temp_backups EXIT

restore_active_backup() {
	if [ -n "${ACTIVE_BACKUP_FILE}" ] && [ -n "${ACTIVE_FILE_PATH}" ]; then
		cp "${ACTIVE_BACKUP_FILE}" "${ACTIVE_FILE_PATH}" || true
	fi
}

abort_update() {
	restore_active_backup
	cleanup_temp_backups
	exit 130
}

trap abort_update INT TERM

resolve_tool() {
	local command_name=$1
	local package_attr=$2
	local path
	local store_paths
	local store_path

	path=$(command -v "${command_name}" || true)
	if [ -n "${path}" ]; then
		printf '%s' "${path}"
		return 0
	fi

	store_paths=$(nix build --no-link --print-out-paths "nixpkgs#${package_attr}")
	while IFS= read -r store_path; do
		if [ -x "${store_path}/bin/${command_name}" ]; then
			printf '%s/bin/%s' "${store_path}" "${command_name}"
			return 0
		fi
	done <<<"${store_paths}"

	printf 'Failed to resolve %s from nixpkgs#%s\n' "${command_name}" "${package_attr}" >&2
	return 1
}

ensure_jq() {
	if [ -z "${JQ_BIN}" ]; then
		JQ_BIN=$(resolve_tool jq jq)
	fi
}

ensure_curl() {
	if [ -z "${CURL_BIN}" ]; then
		CURL_BIN=$(resolve_tool curl curl)
	fi
}

json_query() {
	ensure_jq
	"${JQ_BIN}" "$@"
}

curl_fetch() {
	ensure_curl
	"${CURL_BIN}" -fsSL "$@"
}

run_with_timeout() {
	local label=$1
	local status
	shift

	if [ -z "${UPDATE_TIMEOUT}" ] || [ "${UPDATE_TIMEOUT}" = "0" ]; then
		if "$@"; then
			return 0
		else
			return $?
		fi
	fi

	if ! command -v timeout >/dev/null 2>&1; then
		if "$@"; then
			return 0
		else
			return $?
		fi
	fi

	if timeout --foreground "${UPDATE_TIMEOUT}" "$@"; then
		return 0
	else
		status=$?
	fi

	if [ "${status}" -eq 124 ]; then
		printf 'Timed out after %s: %s\n' "${UPDATE_TIMEOUT}" "${label}" >&2
	fi

	return "${status}"
}

escape_nix_string() {
	local value=$1

	value=${value//\\/\\\\}
	value=${value//\"/\\\"}

	printf '%s' "${value}"
}

nix_eval_attrset() {
	local source_kind=$1
	local attrset=$2
	local apply_expr=$3

	if [ "${source_kind}" = "flake" ]; then
		nix eval --raw ".#${attrset}" --apply "${apply_expr}"
	else
		nix eval --raw --file default.nix "${attrset}" --apply "${apply_expr}"
	fi
}

list_derivations() {
	local source_kind=$1
	local attrset=$2

	nix_eval_attrset "${source_kind}" "${attrset}" '
    pkgs:
      builtins.concatStringsSep "\n"
      (builtins.filter
        (name:
          let v = builtins.getAttr name pkgs;
          in builtins.isAttrs v && v ? type && v.type == "derivation")
        (builtins.attrNames pkgs))'
}

list_file_attrsets() {
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

list_flake_attrsets() {
	if nix eval --raw ".#packages.${SYSTEM}" --apply 'pkgs: ""' >/dev/null 2>&1; then
		printf '%s\n' "packages.${SYSTEM}"
	fi
}

read_package_version() {
	local source_kind=$1
	local attrset=$2
	local attr=$3
	local escaped_attr

	escaped_attr=$(escape_nix_string "${attr}")
	nix_eval_attrset "${source_kind}" "${attrset}" "
    pkgs:
      let pkg = builtins.getAttr \"${escaped_attr}\" pkgs;
      in if builtins.isAttrs pkg && pkg ? version then pkg.version else \"\"" 2>/dev/null || true
}

version_mode_for_version() {
	local version=$1

	if [[ "${version}" =~ (^|[-._])unstable($|[-._0-9]) ]] || [[ "${version}" =~ (^|[-._])git($|[-._0-9]) ]]; then
		printf '%s' branch
	else
		printf '%s' stable
	fi
}

attribute_file_path() {
	local source_kind=$1
	local attrset=$2
	local attr=$3
	local escaped_attr
	local position
	local file_path
	local root_dir
	local candidate

	escaped_attr=$(escape_nix_string "${attr}")
	position=$(nix_eval_attrset "${source_kind}" "${attrset}" "
    pkgs:
      let pkg = builtins.getAttr \"${escaped_attr}\" pkgs;
      in if builtins.isAttrs pkg && pkg ? meta && pkg.meta ? position then pkg.meta.position else \"\"" 2>/dev/null || true)

	if [ -z "${position}" ]; then
		return 1
	fi

	file_path=${position%%:*}
	if [ "${source_kind}" = "flake" ] && [[ "${file_path}" =~ ^/nix/store/[^/]+-source(/.*)$ ]]; then
		file_path="${PWD}${BASH_REMATCH[1]}"
	fi

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

backup_file() {
	local file_path=$1
	local backup_file

	backup_file=$(mktemp)
	TEMP_BACKUP_FILES+=("${backup_file}")
	cp "${file_path}" "${backup_file}"
	printf '%s' "${backup_file}"
}

cleanup_backup_file() {
	local backup_file=${1:-}

	if [ -n "${backup_file}" ]; then
		rm -f "${backup_file}" || true
	fi
}

restore_backup_file() {
	local backup_file=$1
	local file_path=$2

	if [ -n "${backup_file}" ]; then
		cp "${backup_file}" "${file_path}"
	fi
}

begin_file_transaction() {
	ACTIVE_FILE_PATH=$1
	ACTIVE_BACKUP_FILE=$2
}

end_file_transaction() {
	ACTIVE_FILE_PATH=""
	ACTIVE_BACKUP_FILE=""
}

run_nix_update() {
	local source_kind=$1
	local version_mode=$2
	local attr_path=$3

	if [ "${source_kind}" = "flake" ]; then
		run_with_timeout "nix-update ${attr_path}" nix run nixpkgs#nix-update -- --flake --use-github-releases --version="${version_mode}" "${attr_path}"
	else
		run_with_timeout "nix-update ${attr_path}" nix run nixpkgs#nix-update -- -f default.nix --version="${version_mode}" "${attr_path}"
	fi
}

normalize_unstable_version_format() {
	local file_path=$1
	local previous_version=$2
	local current_version=$3
	local prefix=0
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

refresh_dependency_hash() {
	local source_kind=$1
	local attr_path=$2
	local file_path=$3
	local build_output
	local build_status
	local dependency_hash
	local escaped_hash

	if ! grep -Eq 'dependencyHash = "sha256-[^"]+";' "${file_path}"; then
		return 0
	fi

	sed -E -i '0,/dependencyHash = "sha256-[^"]+";/s|dependencyHash = "sha256-[^"]+";|dependencyHash = lib.fakeHash;|' "${file_path}"

	set +e
	if [ "${source_kind}" = "flake" ]; then
		build_output=$(run_with_timeout "nix build ${attr_path}" nix build ".#${attr_path}" --no-link 2>&1)
	else
		build_output=$(run_with_timeout "nix-build ${attr_path}" nix-build -A "${attr_path}" --no-out-link 2>&1)
	fi
	build_status=$?
	set -e

	if [ "${build_status}" -eq 0 ]; then
		return 0
	fi

	dependency_hash=$(printf '%s\n' "${build_output}" | sed -n -E 's/^[[:space:]]*got:[[:space:]]*(sha256-[A-Za-z0-9+/=]+)$/\1/p')
	if [ -z "${dependency_hash}" ]; then
		printf 'Failed to refresh dependencyHash for %s\n' "${attr_path}" >&2
		printf '%s\n' "${build_output}" >&2
		return 1
	fi

	escaped_hash=$(printf '%s' "${dependency_hash}" | sed -e 's/[&|\\]/\\&/g')
	sed -E -i "0,/dependencyHash = lib\.fakeHash;/s|dependencyHash = lib\.fakeHash;|dependencyHash = \"${escaped_hash}\";|" "${file_path}"
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

	[ -n "${before_version}" ] && [ -n "${after_version}" ] && [[ "${before_version}" =~ ^v?[0-9] ]] && [[ "${after_version}" =~ ^v?[0-9] ]]
}

postprocess_package_update() {
	local source_kind=$1
	local attr_path=$2
	local file_path=$3
	local backup_file=$4
	local before_version=$5
	local after_version=$6

	normalize_unstable_version_format "${file_path}" "${before_version}" "${after_version}"

	if ! refresh_dependency_hash "${source_kind}" "${attr_path}" "${file_path}"; then
		restore_backup_file "${backup_file}" "${file_path}"
		return 1
	fi
}

package_has_manifest_updater() {
	local file_path=$1
	local package_dir
	local manifest

	package_dir=$(dirname "${file_path}")
	for manifest in "${package_dir}"/*.json; do
		if [ ! -e "${manifest}" ]; then
			continue
		fi

		if manifest_has_release_asset_updater "${manifest}"; then
			return 0
		fi
	done

	return 1
}

run_package_update() {
	local source_kind=$1
	local attrset=$2
	local attr=$3
	local attr_path="${attrset}.${attr}"
	local before_version
	local after_version
	local version_mode
	local file_path
	local backup_file=""
	local update_status

	before_version=$(read_package_version "${source_kind}" "${attrset}" "${attr}")
	version_mode=$(version_mode_for_version "${before_version}")
	file_path=$(attribute_file_path "${source_kind}" "${attrset}" "${attr}" || true)
	if [ -n "${file_path}" ] && package_has_manifest_updater "${file_path}"; then
		printf 'Skipping %s; manifest updater owns %s\n' "${attr_path}" "${file_path}"
		return 0
	fi

	if [ -n "${file_path}" ] && [ -f "${file_path}" ]; then
		backup_file=$(backup_file "${file_path}")
		begin_file_transaction "${file_path}" "${backup_file}"
	fi

	set +e
	run_nix_update "${source_kind}" "${version_mode}" "${attr_path}"
	update_status=$?
	set -e

	if [ "${update_status}" -ne 0 ]; then
		restore_backup_file "${backup_file}" "${file_path}"
		end_file_transaction
		cleanup_backup_file "${backup_file}"
		if [ "${update_status}" -eq 130 ]; then
			exit 130
		fi
		return 0
	fi

	after_version=$(read_package_version "${source_kind}" "${attrset}" "${attr}")

	if [ -n "${file_path}" ] && [ -f "${file_path}" ]; then
		if ! postprocess_package_update "${source_kind}" "${attr_path}" "${file_path}" "${backup_file}" "${before_version}" "${after_version}"; then
			end_file_transaction
			cleanup_backup_file "${backup_file}"
			return 0
		fi

		after_version=$(read_package_version "${source_kind}" "${attrset}" "${attr}")
	fi

	if [ -n "${backup_file}" ] && should_block_downgrade "${before_version}" "${after_version}" && version_is_older "${after_version}" "${before_version}"; then
		printf 'Reverting apparent downgrade for %s (%s -> %s)\n' "${attr_path}" "${before_version}" "${after_version}" >&2
		restore_backup_file "${backup_file}" "${file_path}"
	fi

	end_file_transaction
	cleanup_backup_file "${backup_file}"
}

run_attrset_updates() {
	local source_kind=$1
	local attrset=$2
	local -a attrs=()
	local attr

	mapfile -t attrs < <(list_derivations "${source_kind}" "${attrset}")
	for attr in "${attrs[@]}"; do
		if [ -n "${attr}" ]; then
			run_package_update "${source_kind}" "${attrset}" "${attr}"
		fi
	done
}

run_discovered_attrsets() {
	local source_kind=$1
	local list_fn=$2
	local -a attrsets=()
	local attrset

	mapfile -t attrsets < <("${list_fn}")
	for attrset in "${attrsets[@]}"; do
		if [ -n "${attrset}" ]; then
			run_attrset_updates "${source_kind}" "${attrset}"
		fi
	done
}

manifest_has_release_asset_updater() {
	local manifest=$1

	json_query -e '.updater.type == "github-release-assets"' "${manifest}" >/dev/null 2>&1
}

manifest_value() {
	local manifest=$1
	local filter=$2

	json_query -r "${filter} // empty" "${manifest}"
}

latest_github_release_tag() {
	local owner=$1
	local repo=$2

	curl_fetch "https://api.github.com/repos/${owner}/${repo}/releases/latest" | json_query -r '.tag_name // empty'
}

strip_tag_prefix() {
	local tag=$1
	local prefix=$2

	if [ -n "${prefix}" ] && [[ "${tag}" == "${prefix}"* ]]; then
		printf '%s' "${tag#"${prefix}"}"
	else
		printf '%s' "${tag}"
	fi
}

release_download_url() {
	local manifest=$1
	local tag=$2
	local asset=$3
	local owner
	local repo
	local template
	local url

	owner=$(manifest_value "${manifest}" '.updater.owner')
	repo=$(manifest_value "${manifest}" '.updater.repo')
	template=$(manifest_value "${manifest}" '.updater.urlTemplate')

	if [ -z "${template}" ]; then
		template='https://github.com/{{owner}}/{{repo}}/releases/download/{{tag}}/{{asset}}'
	fi

	url=${template//\{\{owner\}\}/${owner}}
	url=${url//\{\{repo\}\}/${repo}}
	url=${url//\{\{tag\}\}/${tag}}
	url=${url//\{\{asset\}\}/${asset}}

	printf '%s' "${url}"
}

prefetch_release_asset_hash() {
	local manifest=$1
	local tag=$2
	local system=$3
	local asset
	local url

	# shellcheck disable=SC2016
	asset=$(json_query -r --arg system "${system}" '.updater.assets[$system] // empty' "${manifest}")
	if [ -z "${asset}" ]; then
		printf 'Missing asset mapping for %s in %s\n' "${system}" "${manifest}" >&2
		return 1
	fi

	url=$(release_download_url "${manifest}" "${tag}" "${asset}")
	run_with_timeout "prefetch ${url}" nix store prefetch-file --json --hash-type sha256 "${url}" | json_query -r '.hash'
}

prefetch_release_asset_hashes() {
	local manifest=$1
	local tag=$2
	local hashes_file=$3
	local -a systems=()
	local system
	local hash
	local next_file

	mapfile -t systems < <(json_query -r '.updater.assets | keys[]' "${manifest}")
	printf '{}\n' >"${hashes_file}"

	for system in "${systems[@]}"; do
		hash=$(prefetch_release_asset_hash "${manifest}" "${tag}" "${system}")
		next_file=$(mktemp)
		TEMP_BACKUP_FILES+=("${next_file}")
		# shellcheck disable=SC2016
		json_query --arg system "${system}" --arg hash "${hash}" '. + {($system): $hash}' "${hashes_file}" >"${next_file}"
		mv "${next_file}" "${hashes_file}"
	done
}

write_release_asset_manifest() {
	local manifest=$1
	local version=$2
	local hashes_file=$3
	local next_file

	next_file=$(mktemp)
	TEMP_BACKUP_FILES+=("${next_file}")
	# shellcheck disable=SC2016
	json_query --arg version "${version}" --slurpfile hashes "${hashes_file}" '.version = $version | .hashes = $hashes[0]' "${manifest}" >"${next_file}"
	mv "${next_file}" "${manifest}"
}

update_release_asset_manifest() {
	local manifest=$1
	local owner
	local repo
	local tag_prefix
	local current_version
	local latest_tag
	local latest_version
	local hashes_file

	if ! manifest_has_release_asset_updater "${manifest}"; then
		return 0
	fi

	owner=$(manifest_value "${manifest}" '.updater.owner')
	repo=$(manifest_value "${manifest}" '.updater.repo')
	tag_prefix=$(manifest_value "${manifest}" '.updater.tagPrefix')
	current_version=$(manifest_value "${manifest}" '.version')

	if [ -z "${owner}" ] || [ -z "${repo}" ]; then
		printf 'Skipping incomplete release asset manifest: %s\n' "${manifest}" >&2
		return 0
	fi

	latest_tag=$(latest_github_release_tag "${owner}" "${repo}")
	latest_version=$(strip_tag_prefix "${latest_tag}" "${tag_prefix}")

	if [ -z "${latest_version}" ]; then
		printf 'Failed to determine latest release version for %s/%s\n' "${owner}" "${repo}" >&2
		return 1
	fi

	if should_block_downgrade "${current_version}" "${latest_version}" && version_is_older "${latest_version}" "${current_version}"; then
		printf 'Skipping apparent downgrade for %s (%s -> %s)\n' "${manifest}" "${current_version}" "${latest_version}" >&2
		return 0
	fi

	if [ "${current_version}" = "${latest_version}" ]; then
		printf '%s already up to date at %s\n' "${manifest}" "${current_version}"
		return 0
	fi

	printf 'Updating %s from %s to %s\n' "${manifest}" "${current_version}" "${latest_version}"

	hashes_file=$(mktemp)
	TEMP_BACKUP_FILES+=("${hashes_file}")
	prefetch_release_asset_hashes "${manifest}" "${latest_tag}" "${hashes_file}"
	write_release_asset_manifest "${manifest}" "${latest_version}" "${hashes_file}"
}

list_release_asset_manifests() {
	find pkgs -name '*.json' -type f | sort
}

update_release_asset_manifests() {
	local manifest

	while IFS= read -r manifest; do
		update_release_asset_manifest "${manifest}"
	done < <(list_release_asset_manifests)
}

main() {
	run_discovered_attrsets flake list_flake_attrsets
	run_discovered_attrsets file list_file_attrsets
	update_release_asset_manifests
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi
