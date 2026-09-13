# Single bubblewrap sandbox for Bitwig Studio.
#
# Why not Firejail: nixpkgs already launches Bitwig under bwrap to overlay a
# writable copy of resources/VampTransforms (read-only store templates break
# onset/beat detection via Java COPY_ATTRIBUTES). Nesting Firejail outside that
# bwrap fails with `Failed to make / slave: Operation not permitted`
# (mount blocked; see firejail#4366 / nixpkgs bitwig-studio6 postFixup).
#
# Why --bind / /: Flathub finish-args use --filesystem=host for the same reason
# (media/projects/plugins live anywhere). Persist dirs match Flatpak:
#   https://github.com/flathub/com.bitwig.BitwigStudio/blob/master/com.bitwig.BitwigStudio.yaml
#
# Offline after activation (blocks updates/content packs/auth):
#   BITWIG_BWRAP_NET_NONE=1 bitwig-studio
{
  stdenvNoCC,
  bubblewrap,
  coreutils,
  writeShellScript,
  bitwig-studio,
}:

stdenvNoCC.mkDerivation {
  pname = bitwig-studio.pname;
  inherit (bitwig-studio) version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase =
    let
      # Call libexec directly — never bin/bitwig-studio (that is nixpkgs' own bwrap).
      wrapper = writeShellScript "bitwig-studio" ''
        set -euo pipefail

        outDir=${bitwig-studio}
        TMPDIR="$(${coreutils}/bin/mktemp --directory)"
        cleanup() { ${coreutils}/bin/rm -rf "$TMPDIR"; }
        trap cleanup EXIT

        ${coreutils}/bin/cp -r "$outDir"/libexec/resources/VampTransforms "$TMPDIR"
        ${coreutils}/bin/chmod -R u+w "$TMPDIR/VampTransforms"

        net_args=()
        if [ "''${BITWIG_BWRAP_NET_NONE:-}" = 1 ]; then
          net_args=(--unshare-net)
        fi

        ${bubblewrap}/bin/bwrap \
          --bind / / \
          --dev-bind /dev /dev \
          --bind "$TMPDIR"/VampTransforms "$outDir"/libexec/resources/VampTransforms \
          --die-with-parent \
          "''${net_args[@]}" \
          "$outDir"/libexec/bitwig-studio \
          "$@"
      '';
    in
    ''
      runHook preInstall
      mkdir -p "$out/bin"
      install -m755 ${wrapper} "$out/bin/bitwig-studio"
      ln -s ${bitwig-studio}/share "$out/share"
      runHook postInstall
    '';

  meta = bitwig-studio.meta // {
    description = "${bitwig-studio.meta.description or "Bitwig Studio"} (single bwrap sandbox)";
    mainProgram = "bitwig-studio";
  };
}
