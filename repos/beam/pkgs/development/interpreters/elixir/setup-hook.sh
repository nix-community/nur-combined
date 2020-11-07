# CAVEAT: This file is excluded from generic-builder.sh

addErlLibPath() {
    local lib=$1/lib/elixir/lib
    if [[ ! ${ERL_LIBS:-} =~ $lib ]]; then
        addToSearchPath ERL_LIBS $lib
    fi
}

addEnvHooks "$hostOffset" addErlLibPath