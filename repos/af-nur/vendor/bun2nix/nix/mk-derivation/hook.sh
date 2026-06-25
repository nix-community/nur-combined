# shellcheck shell=bash

# shellcheck disable=SC2034
readonly bunDefaultInstallFlagsArray=(@bunDefaultInstallFlags@)

function bunSetInstallCacheDirPhase {
  runHook preBunSetInstallCacheDirPhase

  if ! [ -v bunDeps ]; then
    printf '\n\033[31mError:\033[0m %s\n\n' "$(
      cat <<'EOF'
Please set `bunDeps` in order to use `bun2nix.hook` or
`bun2nix.mkDerivation` to build your package.

# Example
```nix
stdenv.mkDerivation {
  <other inputs>

  nativeBuildInputs = [
    bun2nix.hook
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
}
```
EOF
    )" >&2

    exit 1
  fi

  BUN_INSTALL_CACHE_DIR=$(mktemp -d)
  export BUN_INSTALL_CACHE_DIR

  # Use -RL to dereference symlinks so bun finds actual directories
  cp -r "$bunDeps"/share/bun-cache/. "$BUN_INSTALL_CACHE_DIR"

  if ! [ -v bunRoot ]; then
    bunRoot=$(pwd)
  else
    local subDir
    subDir="$(pwd)/$bunRoot"

    if ! [ -d "$subDir" ]; then
      printf '\n\033[31mError:\033[0m %s\n\n' "$(
        cat <<'EOF'
`bunRoot` should be a sub directory of the current working directory.

An easy mistake to make is accidentally passing a nix path literal,
which gets copied to the nix store separately:

```nix
bunRoot = ./assets; # (incorrect)
```

You may fix this by simply passing a string instead:

```nix
bunRoot = "assets"; # (correct)
```
EOF
      )" >&2
      exit 1
    fi
  fi

  echo "Using bun root: \"$bunRoot\""

  runHook postBunSetInstallCacheDirPhase
}

function bunPatchPhase {
  runHook preBunPatchPhase

  patchShebangs .

  HOME=$(mktemp -d)
  export HOME

  runHook postBunPatchPhase
}

# bun re-resolves `catalog:` dependency specifiers against the npm registry on
# every `bun install`, even with a fully populated cache. In the Nix sandbox
# this fails. The lockfile already records the exact resolved version for
# every package, so rewrite every `catalog:` reference (in bun.lock's
# `workspaces` section and in every workspace package.json) to that exact
# version (or `workspace:*` for workspace packages) before `bun install`.
function bunResolveCatalogRefs {
  if ! [ -f bun.lock ] || ! grep -q '"catalog:' bun.lock 2>/dev/null; then
    return 0
  fi
  # --config=/dev/null: ignore the project's bunfig.toml, which may remap
  #   the .ts loader and silently turn the script into a no-op.
  # --no-install: never attempt auto-install for the helper script.
  bun --config=/dev/null --no-install @resolveCatalogTs@ .
}

function bunNodeModulesInstallPhase {
  pushd "$bunRoot" || exit 1
  runHook preBunNodeModulesInstallPhase

  bunResolveCatalogRefs

  # Remove patchedDependencies from package.json and bun.lock since we
  # pre-patch packages during the Nix build. This ensures bun looks for
  # packages at the normal cache keys (without patch hash suffix).
  if [ -f package.json ] && grep -q '"patchedDependencies"' package.json 2>/dev/null; then
    yq -o=json 'del(.patchedDependencies)' package.json >package.json.tmp && mv package.json.tmp package.json
  fi
  if [ -f bun.lock ] && grep -q '"patchedDependencies"' bun.lock 2>/dev/null; then
    yq -o=json 'del(.patchedDependencies)' bun.lock >bun.lock.tmp && mv bun.lock.tmp bun.lock
  fi

  local flagsArray=()
  if [ -z "${bunInstallFlags-}" ] && [ -z "${bunInstallFlagsArray-}" ]; then
    concatTo flagsArray \
      bunDefaultInstallFlagsArray
  else
    concatTo flagsArray \
      bunInstallFlags bunInstallFlagsArray
  fi

  local ignoreFlagsArray=("--ignore-scripts")
  concatTo flagsArray ignoreFlagsArray

  echoCmd 'bun install flags' "${flagsArray[@]}"
  bun install "${flagsArray[@]}"

  runHook postBunNodeModulesInstallPhase
  popd || exit 1
}

function bunLifecycleScriptsPhase {
  pushd "$bunRoot" || exit 1
  runHook preBunLifecycleScriptsPhase

  chmod -R u+rwx ./node_modules

  local flagsArray=()
  if [ -z "${bunInstallFlags-}" ] && [ -z "${bunInstallFlagsArray-}" ]; then
    concatTo flagsArray \
      bunDefaultInstallFlagsArray
  else
    concatTo flagsArray \
      bunInstallFlags bunInstallFlagsArray
  fi

  echoCmd 'bun lifecycle install flags' "${flagsArray[@]}"
  bun install "${flagsArray[@]}"

  runHook postBunLifecycleScriptsPhase
  popd || exit 1
}

function bunBuildPhase {
  pushd "$bunRoot" || exit 1
  runHook preBuild

  local flagsArray=()
  concatTo flagsArray \
    bunBuildFlags bunBuildFlagsArray

  echoCmd 'bun build flags' "${flagsArray[@]}"
  bun build "${flagsArray[@]}"

  runHook postBuild
  popd || exit 1
}

function bunCheckPhase {
  pushd "$bunRoot" || exit 1
  runHook preCheck

  local flagsArray=()
  concatTo flagsArray \
    bunCheckFlags bunCheckFlagsArray

  echoCmd 'bun check flags' "${flagsArray[@]}"
  bun test "${flagsArray[@]}"

  runHook postCheck
  popd || exit 1
}

function bunInstallPhase {
  pushd "$bunRoot" || exit 1
  runHook preInstall

  if ! [ -v pname ]; then
    printf '\033[31mError:\033[0m %s.\n' "'pname' was not defined, please make sure you are running this in a nix build script"
    exit 1
  fi
  if ! [ -v out ]; then
    printf '\033[31mError:\033[0m %s.\n' "'out' was not defined, please make sure you are running this in a nix build script"
    exit 1
  fi

  install -Dm755 "$pname" "$out/bin/$pname"

  runHook postInstall
  popd || exit 1
}

appendToVar preConfigurePhases bunSetInstallCacheDirPhase
appendToVar preBuildPhases bunNodeModulesInstallPhase

if [ -z "${dontRunLifecycleScripts-}" ]; then
  appendToVar preBuildPhases bunLifecycleScriptsPhase
fi

if [ -z "${dontUseBunPatch-}" ]; then
  appendToVar preConfigurePhases bunPatchPhase
fi

if [ -z "${dontUseBunBuild-}" ] && [ -z "${buildPhase-}" ]; then
  buildPhase=bunBuildPhase
fi

if [ -z "${dontUseBunCheck-}" ] && [ -z "${checkPhase-}" ]; then
  checkPhase=bunCheckPhase
fi

if [ -z "${dontUseBunInstall-}" ] && [ -z "${installPhase-}" ]; then
  installPhase=bunInstallPhase
fi
