#!/bin/sh

echo "Unpacking nix...."

# If "builder" set, assume busybox bootstrap
if [ -n "$builder" ]; then
  MKDIR="$builder mkdir"
  TAR="$builder tar"
  UNXZ="$builder unxz"
else
  MKDIR=$(command -v mkdir)
  TAR=$(command -v tar)
  UNXZ=$(command -v unxz)
fi

echo "Using utilities:"
echo "  MKDIR = $MKDIR"
echo "  TAR   = $TAR"
echo "  UNXZ  = $UNXZ"

tarball=${tarball:-$1}
out=${out:-$2}

echo "Parameters:"
echo "  tarball: $tarball"
echo "  out:     $out"

$MKDIR $out
< $tarball $UNXZ | EXTRACT_UNSAFE_SYMLINKS=1 $TAR xv -C $out

# Cleanup after ourselves
REMOVES="$PWD/nix-copy $PWD/bin"
trap 'rm -rf $REMOVES' EXIT

# Add unpacked tarball to $PATH, gives us many utilities
export PATH=$out/bin:$out/libexec/nix:$PATH

# Copy the binary and use it while fixing up paths
# to avoid any problems with modifying the tools as we use them

cp $out/bin/nix nix-copy
mkdir bin
ln -s ../nix-copy bin/sed
ln -s ../nix-copy bin/find # currently unused

export SED=$PWD/bin/sed

for x in $out/etc/*/*.conf $out/etc/*/*.sh $out/lib/*/*/* $out/share/nix/*/*; do
  if [ -L "$x" ]; then continue; fi

  # Not right for ref's to openssl but oh well
  $SED -e "s|/nix/store/e*-[^/]*/|$out/|g" -i "$x"
done
# Touchup nixPrefix
$SED -e "s|/nix/store/e*-[^/\"]*|$out|g" -i "$out/share/nix/corepkgs/config.nix"

# remove bb-based utils included only for bootstrap
rm $out/libexec/nix/sed
rm $out/libexec/nix/find

