#!/usr/bin/env bash
# This script dispatches invocations transparently to programs instantiated from
# Nix.
#
# To add a new tool, insert it into the case statement below by setting `attr`
# to the key in nixpkgs which represents the program you want to run.
set -ueo pipefail

readonly REPO_ROOT=$(dirname "$0")/..
TARGET_TOOL=$(basename "$0")

case "${TARGET_TOOL}" in
    bus)
        attr="tools.bus"
        ;;
    k8s.infra)
        attr="tools.k8s_infra"
        ;;
    *)
        echo "The tool '${TARGET_TOOL}' is currently not installed in this repository."
        exit 1
        ;;
esac

result=$(nix-build --no-out-link --attr "${attr}" "${REPO_ROOT}")
PATH="${result}/bin:$PATH"

exec "${TARGET_TOOL}" "${@}"
