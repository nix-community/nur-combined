#!/bin/sh

# Find cmake in PATH that is not this wrapper
CMAKE=$(which -a cmake | grep -v "\.bin/cmake" | head -n 1)

for arg do
    shift
    case "$arg" in
        *"/cargokit/run_build_tool.sh")
            set -- "$@" "sh" "$arg"
            ;;
        *)
            set -- "$@" "$arg"
            ;;
    esac
done

exec "$CMAKE" "$@"
