# CAVEAT: Commented out file due to incorrect warnings regarding Elixir like following.
#
# warning: this clause cannot match because a previous clause at line 6 always matches
#   lib/inspect.ex:6
#

# addErlLibPath() {
#     local lib=$1/lib/elixir/lib
#     if [[ ! ${ERL_LIBS:-} =~ $lib ]]; then
#         addToSearchPath ERL_LIBS $lib
#     fi
# }

# addEnvHooks "$hostOffset" addErlLibPath