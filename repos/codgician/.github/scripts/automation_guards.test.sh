#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

assert_state() {
  local old_version=$1
  local new_version=$2
  local expected=$3
  local actual
  actual=$(.github/scripts/classify_version.sh "$old_version" "$new_version")
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected $old_version -> $new_version to be $expected, got $actual" >&2
    exit 1
  fi
}

assert_route() {
  local updater_exit=$1
  local package_changes=$2
  local version_state=$3
  local deterministic_exit=$4
  local expected=$5
  local actual
  actual=$(.github/scripts/select_update_route.sh \
    "$updater_exit" \
    "$package_changes" \
    "$version_state" \
    "$deterministic_exit")
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected route $expected, got $actual" >&2
    exit 1
  fi
}

assert_state '0-unstable-2026-07-15' '0-unstable-2026-07-16' advanced
assert_state '0-unstable-2026-07-15' '0-unstable-2026-07-15' unchanged
assert_state '0-unstable-2026-07-15' '0-unstable-2026-07-14' regressed
assert_state '1.2.3' '1.2.4' advanced

assert_route 0 true unchanged '' up-to-date
assert_route 0 false '' '' up-to-date
assert_route 0 true advanced 0 deterministic
assert_route 0 true advanced 1 ai
assert_route 1 true '' '' ai
assert_route 0 true invalid '' ai

if .github/scripts/classify_version.sh \
  '0-unstable-2026-07-15' \
  '0-unstable-2026-07-15-180007' >/dev/null 2>&1; then
  echo 'Timestamped version unexpectedly passed the date-only format guard' >&2
  exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/package"
printf 'safe\n' > "$tmpdir/package/update.sh"
.github/scripts/validate_package_source.sh "$tmpdir/package"
ln -s "$tmpdir/package" "$tmpdir/package-link"
if .github/scripts/validate_package_source.sh "$tmpdir/package-link" >/dev/null 2>&1; then
  echo 'Symlinked package path unexpectedly passed the package-source guard' >&2
  exit 1
fi
printf 'DENDRO_API_KEY\n' >> "$tmpdir/package/update.sh"
if .github/scripts/validate_package_source.sh "$tmpdir/package" >/dev/null 2>&1; then
  echo 'CI credential reference unexpectedly passed the package-source guard' >&2
  exit 1
fi

mkdir -p "$tmpdir/bin"
cat > "$tmpdir/bin/nix" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

case ${1-} in
  eval)
    printf '%s\n' "${MOCK_NIX_TESTS_JSON:?}"
    ;;
  build)
    printf '%s\n' "$@" > "${MOCK_NIX_BUILD_ARGS:?}"
    ;;
  *)
    echo "Unexpected mocked nix command: ${1-}" >&2
    exit 1
    ;;
esac
EOF
chmod +x "$tmpdir/bin/nix"

build_args_file="$tmpdir/build-args"
PATH="$tmpdir/bin:$PATH" \
  MOCK_NIX_TESTS_JSON='["/nix/store/first-test.drv","/nix/store/second-test.drv"]' \
  MOCK_NIX_BUILD_ARGS="$build_args_file" \
  .github/scripts/run_smoke_test.sh fixture /nix/store/fixture none
mapfile -t build_args < "$build_args_file"
if (( ${#build_args[@]} != 4 )) \
  || [[ "${build_args[0]}" != build ]] \
  || [[ "${build_args[1]}" != --no-link ]] \
  || [[ "${build_args[2]}" != /nix/store/first-test.drv ]] \
  || [[ "${build_args[3]}" != /nix/store/second-test.drv ]]; then
  echo 'Package test harness did not build every declared test' >&2
  exit 1
fi

rm -f "$build_args_file"
PATH="$tmpdir/bin:$PATH" \
  MOCK_NIX_TESTS_JSON='[]' \
  MOCK_NIX_BUILD_ARGS="$build_args_file" \
  .github/scripts/run_smoke_test.sh fixture /nix/store/fixture none
if [[ -e "$build_args_file" ]]; then
  echo 'Package test harness invoked nix build without declared tests' >&2
  exit 1
fi

models=$(PACKAGE=pi-guard-test DENDRO_API_KEY=test .github/scripts/run_pi_agent.sh --check)
if [[ "$models" != *dendro* || "$models" != *grok-4.5* ]]; then
  echo 'Pinned Pi environment did not load the Dendro model' >&2
  exit 1
fi
