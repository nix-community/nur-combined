# shellcheck shell=bash
# Setup hook that provides a writable HOME for versionCheckHook.
# dsh creates its state directory ($DSH_HOME, default ~/.dsh) even for
# `--version`, so the version check needs a writable HOME.
# (Same approach as llm-agents.nix's versionCheckHomeHook, inlined here
# because nixpkgs does not ship this hook.)

versionCheckHome() {
  if [[ ! -v HOME ]] || [[ ! -w $HOME ]]; then
    HOME="$NIX_BUILD_TOP/.version-check-home"
    mkdir -p "$HOME"
    export HOME
  fi
  # Add HOME to the list of env vars passed through to the version check command
  # Skip if already keeping all env vars
  if [[ ${versionCheckKeepEnvironment:-} != "*" ]]; then
    versionCheckKeepEnvironment="${versionCheckKeepEnvironment-} HOME"
  fi
}

preVersionCheckHooks+=(versionCheckHome)
