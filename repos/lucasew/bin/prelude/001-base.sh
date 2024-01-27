function bold {
    printf "$(tput bold)$*$(tput sgr0)"
}

function red {
    printf "$(tput setaf 1)$*$(tput sgr0)"
}

function green {
    printf "$(tput setaf 2)$*$(tput sgr0)"
}

function yellow {
    printf "$(tput setaf 3)$*$(tput sgr0)"
}

function error {
    echo "$(red "error"): $*"
    exit 1
}

function warning {
    echo "$(yellow "warn"): $*"
}

function info {
    echo "$(green "info"): $*"
}

function now {
    date -u -Iseconds
}

function now_unix {
    date -u +%s
}

function timestamped {
    while read line; do
        echo "$(now) $line"
    done
}

function random_id {
    head -c 128 /dev/urandom | md5sum | tr -d ' -'
}

function has_binary {
    binary=$1; shift
    command -v "$binary" > /dev/null
}

function must_binary {
    binary=$1;shift
    has_binary "$binary" || {
        echo "command '$binary' not found"
        exit 1
    }
}
