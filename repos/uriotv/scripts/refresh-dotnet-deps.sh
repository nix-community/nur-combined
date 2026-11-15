#!/usr/bin/env bash
# Regenerates the NuGet lock (deps.json) of every .NET package against the
# current flake.lock. A nixpkgs bump moves the .NET SDK patch version, and the
# offline restore then needs runtime packs that the old lock does not list.
# fetch-deps only downloads fixed-output NuGet packages; it compiles nothing.
#
# Every package built with buildDotnetModule must be listed here; this is
# enforced by tests/dotnet-deps.py.
set -euo pipefail

# attribute (under packages.x86_64-linux) : lock file
DOTNET_DEPS=(
  "lantern-engine.launcher:pkgs/lantern-engine/deps.json"
)

# Every refresh gets a fresh private TMPDIR/HOME that is removed afterwards, so
# no .NET CLI first-use state leaks between runs. (The runner's former
# "cannot open the device or file: 'NuGet-Migrations'" failure had another
# cause: see the NuGet migration marker in the package's postPatch.)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export DOTNET_NOLOGO=1 DOTNET_CLI_TELEMETRY_OPTOUT=1

status=0
for entry in "${DOTNET_DEPS[@]}"; do
  attr=${entry%%:*}
  lock=${entry#*:}
  echo "::group::Refresh $lock ($attr)"
  # Start from an empty lock: a stale lock can itself break fetch-deps (e.g. its
  # runtime packs collide with ones the new SDK ships: "ln: ... File exists").
  echo '[]' > "$lock"
  env_dir=$(mktemp -d "$scratch/env.XXXXXX")
  mkdir -p "$env_dir/tmp" "$env_dir/home"
  if fetch_deps=$(nix build --no-link --print-out-paths --no-write-lock-file \
        ".#packages.x86_64-linux.${attr}.fetch-deps") &&
     TMPDIR="$env_dir/tmp" HOME="$env_dir/home" DOTNET_CLI_HOME="$env_dir/home" \
       "$fetch_deps" "$lock"; then
    echo "Refreshed $lock"
  else
    echo "::error::Failed to refresh $lock ($attr)"
    git checkout -- "$lock" 2>/dev/null || true
    status=1
  fi
  echo '::endgroup::'
done
exit "$status"
