{
  lib,
  stdenv,
  version,
  releaseDmg,
}:

# The guest kernel, initramfs and read-only layer are built by upstream in
# privileged Linux containers from Valve's OTA rootfs; that cannot run inside a
# Nix build on macOS. Take the signed artifacts (and their GPL license
# inventory) from the matching upstream release instead, pinned by the DMG hash
# in package.nix.
stdenv.mkDerivation {
  name = "steamac-guest-images-${version}";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Plain data; the default fixup would run the host's BSD find over it.
  dontFixup = true;

  # hdiutil needs /dev and the host's diskimages framework.
  __noChroot = true;

  installPhase = ''
    runHook preInstall

    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    mnt=$TMPDIR/dmg
    mkdir -p "$mnt" "$out"
    hdiutil attach -nobrowse -readonly -mountpoint "$mnt" ${releaseDmg} > /dev/null
    trap 'hdiutil detach "$mnt" > /dev/null || true' EXIT

    res="$mnt/FX Steam Launcher.app/Contents/Resources"
    for f in Image initramfs.cpio.gz steamac-layer.img \
             Image.inputs.json initramfs.cpio.gz.inputs.json steamac-layer.img.inputs.json; do
      cp "$res/$f" "$out/$f"
    done
    cp -R "$res/licenses" "$out/licenses"

    hdiutil detach "$mnt" > /dev/null
    trap - EXIT

    runHook postInstall
  '';

  meta = {
    description = "Signed SteamOS guest images shipped with FX Steam Launcher";
    homepage = "https://github.com/fxgl/steamac";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
  };
}
