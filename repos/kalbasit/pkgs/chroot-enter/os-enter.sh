#!/usr/bin/env bash

set -eo pipefail

# Re-exec ourselves in a private mount namespace so that our bind
# mounts get cleaned up automatically.
if [ -z "$OS_ENTER_REEXEC" ]; then
    export OS_ENTER_REEXEC=1
    if [ "$(id -u)" != 0 ]; then
        extraFlags="-r"
    fi
    exec unshare --fork --mount --uts --mount-proc --pid $extraFlags -- "$0" "$@"
else
    mount --make-rprivate /
fi

mountPoint=/mnt

while [ "$#" -gt 0 ]; do
    i="$1"; shift 1
    case "$i" in
        --root)
            mountPoint="$1"; shift 1
            ;;
        --help)
            exec man nixos-enter
            exit 1
            ;;
        --command|-c)
            command=("$@")
            shift 1
            ;;
        --)
            command=("$@")
            break
            ;;
        *)
            echo "$0: unknown option \`$i'"
            exit 1
            ;;
    esac
done

if [[ -z "${command}" ]]; then
    if [[ -x "${mountPoint}/bin/bash" ]]; then
        command=("/bin/bash")
    elif [[ -x "${mountPoint}/usr/bin/bash" ]]; then
        command=("/usr/bin/bash")
    else
        echo "ERR: cannot find bash!"
        exit 1
    fi

    command=(${command[@]} "--login")
fi

mkdir -m 0755 -p "$mountPoint/proc" "$mountPoint/dev" "$mountPoint/sys"
mount --rbind /proc "$mountPoint/proc"
mount --rbind /dev "$mountPoint/dev"
mount --rbind /sys "$mountPoint/sys"
mount --rbind /etc/resolv.conf "$mountPoint/etc/resolv.conf"

exec chroot "$mountPoint" "${command[@]}"
