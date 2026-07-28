#!/usr/bin/env bash
:

# shellcheck source=../packages/shellvaculib/shellvaculib.bash
source shellvaculib.bash || exit 1

# declare make_appendable="false"
#
# declare -a file_args=()
#
# while [[ $# != 0 ]]; do
#   declare arg="$1"
#   shift
#   case "$arg";
#     -a|--appendable)
#       make_appendable="true"
#       ;;
#     --)
#       file_args+=("$@")
#       shift $#
#       ;;
#     -*)
#       svl_die "unrecognized option $arg"
#       ;;
#     *)
#       file_args+=("$arg")
#       ;;
#   esac
# done
#
# if [[ ${#file_args[@]} == 0 ]]; then
#   svl_die "must give at least one file/folder to operate on"
# fi

svl_min_args $# 1

svl_auto_sudo

set -x
chown --recursive archived:archived -- "$@"
chmod --recursive a-w -- "$@"
