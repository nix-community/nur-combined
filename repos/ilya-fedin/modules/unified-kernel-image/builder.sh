#! @bash@/bin/sh -e

shopt -s nullglob

export PATH=/empty
for i in @path@; do PATH=$PATH:$i/bin; done

default=$1
if test -z "$1"; then
    echo "Syntax: unified-kernel-image-builder.sh <DEFAULT-CONFIG>"
    exit 1
fi

echo "generating unified kernel images..."

prefix=@efiSysMountPoint@/EFI/Linux

mkdir -p $prefix

rm -Rf $prefix/nixos-*.efi || true
rm -Rf $prefix/nixos.efi || true

addEntry() {
    local path="$1"
    local generation="$2"
    local infile=@systemd@/lib/systemd/boot/efi/linuxx64.efi.stub
    local outfile=$prefix/nixos-$generation.efi
    local defaultoutfile=$prefix/nixos.efi

    if ! test -e $path/kernel -a -e $path/initrd; then
        return
    fi

    local osrel=$(readlink -f /etc/os-release)
    local kernel=$(readlink -f $path/kernel)
    local initrd=$(readlink -f $path/initrd)
    local init=$(readlink -f $path/init)
    local kernelParams=$(readlink -f $path/kernel-params)
    local cmdline=$(mktemp)

    cat <<EOF > $cmdline
init=$init $(cat $kernelParams)
EOF

    objcopy \
        --add-section .osrel="$osrel" --change-section-vma .osrel=0x20000 \
        --add-section .cmdline="$cmdline" --change-section-vma .cmdline=0x30000 \
        --add-section .linux="$kernel" --change-section-vma .linux=0x2000000 \
        --add-section .initrd="$initrd" --change-section-vma .initrd=0x3000000 \
        "$infile" "$outfile"

    if test $(readlink -f "$path") = "$default"; then
        objcopy \
            --add-section .osrel="$osrel" --change-section-vma .osrel=0x20000 \
            --add-section .cmdline="$cmdline" --change-section-vma .cmdline=0x30000 \
            --add-section .linux="$kernel" --change-section-vma .linux=0x2000000 \
            --add-section .initrd="$initrd" --change-section-vma .initrd=0x3000000 \
            "$infile" "$defaultoutfile"
    fi
}

# Add all generations of the system profile to the menu, in reverse
# (most recent to least recent) order.
for generation in $(
    (cd /nix/var/nix/profiles && ls -d system-*-link) \
    | sed 's/system-\([0-9]\+\)-link/\1/' \
    | sort -n -r); do
    link=/nix/var/nix/profiles/system-$generation-link
    addEntry $link $generation
done
