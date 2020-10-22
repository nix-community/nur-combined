addErlangLibPath() {
    local lib = $1/lib/erlang/lib
    if [[ ! ${ERL_LIBS:-} =~ $lib ]]; then
        addToSearchPath ERL_LIBS $lib
    fi
}

addEnvHooks "$hostOffset" addErlangLibPath
