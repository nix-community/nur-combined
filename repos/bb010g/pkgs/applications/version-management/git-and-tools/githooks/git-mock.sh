declare +ga argv0="$0"
declare +gx -A cmds
cmds=()

_run_cmd() {
  declare +gx cmd="$1"; shift
  "${cmds["$cmd"]-_cmd_not_found}" "$@"
}

_cmd_not_found() {
}

cmds[config] = cmd_config
cmd_config() {
}

_run_cmd "$@"

# vim:et:sw=2:tw=78
