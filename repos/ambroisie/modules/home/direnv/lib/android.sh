# shellcheck shell=bash

# shellcheck disable=2155
use_android() {
    if [ -z "$ANDROID_HOME" ]; then
        log_error "use_android: 'ANDROID_HOME' is not defined"
        return 1
    fi

    _use_android_find_latest() {
        local path="$1"
        local version

        version="$(semver_search "$path" "" "")"
        if [ -z "$version" ]; then
            log_error "use_android: did not find any version at '$path'"
            return 1
        fi

        printf '%s' "$version"
    }

    # Default to the latest version found
    local ndk_version="$(_use_android_find_latest "$ANDROID_HOME/ndk" || return 1)"
    local build_tools_version="$(_use_android_find_latest "$ANDROID_HOME/build-tools" || return 1)"

    unset -f _use_android_find_latest

    # Allow changing the default version through a command line switch
    while true; do
        case "$1" in
            -b|--build-tools)
                build_tools_version="$2"
                shift 2
                if ! [ -e "$ANDROID_HOME/build-tools/$build_tools_version" ]; then
                    log_error "use_android: build-tools version '$build_tools_version' does not exist"
                fi
                ;;
            -n|--ndk)
                ndk_version="$2"
                shift 2
                if ! [ -e "$ANDROID_HOME/ndk/$ndk_version" ]; then
                    log_error "use_android: NDK version '$ndk_version' does not exist"
                fi
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done

    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/$ndk_version"
    export ANDROID_ROOT="$ANDROID_HOME"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"

    PATH_add "$ANDROID_NDK_HOME"
    PATH_add "$ANDROID_HOME/build-tools/$build_tools_version"
}
