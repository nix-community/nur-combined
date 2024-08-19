{
  stdenv,
  gsound,
  libgda6,
  lib,
  fetchzip,
  substituteAll,
  buildPackages,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pano";
  version = "23-alpha2";
  src = fetchzip {
    url = "https://github.com/oae/gnome-shell-pano/releases/download/v${version}/pano@elhan.io.zip";
    hash = "sha256-EHWcRYwAQksbYb/TP1U/MukYZYBpApCw8KH+McdWqIw=";
    stripRoot = false;
    postFetch = ''
      echo "ewogICJuYW1lIjogIlBhbm8gLSBDbGlwYm9hcmQgTWFuYWdlciIsCiAgImRlc2NyaXB0aW9uIjogIk5leHQtZ2VuIENsaXBib2FyZCBtYW5hZ2VyIGZvciBHbm9tZSBTaGVsbFxuXG5Zb3UgbmVlZCBsaWJnZGEgYW5kIGdzb3VuZCBmb3IgdGhpcyBleHRlbnNpb24gdG8gd29yay5cblxuRmVkb3JhOiBzdWRvIGRuZiBpbnN0YWxsIGxpYmdkYSBsaWJnZGEtc3FsaXRlXG5BcmNoIExpbnV4OiBzdWRvIHBhY21hbiAtUyBsaWJnZGEgKGxpYmdkYTYgZm9yIGdub21lLTQzIG9yIGxhdGVyKVxuVWJ1bnR1L0RlYmlhbjogc3VkbyBhcHQgaW5zdGFsbCBnaXIxLjItZ2RhLTUuMCBnaXIxLjItZ3NvdW5kLTEuMFxub3BlblNVU0U6IHN1ZG8genlwcGVyIGluc3RhbGwgbGliZ2RhLTZfMC1zcWxpdGUgdHlwZWxpYi0xXzAtR2RhLTZfMCB0eXBlbGliLTFfMC1HU291bmQtMV8wIiwKICAidXVpZCI6ICJwYW5vQGVsaGFuLmlvIiwKICAiZ2V0dGV4dC1kb21haW4iOiAicGFub0BlbGhhbi5pbyIsCiAgInZlcnNpb24iOiAxMDAxLAogICJkb25hdGlvbnMiOiB7CiAgICAiZ2l0aHViIjogIm9hZSIKICB9LAogICJzZXR0aW5ncy1zY2hlbWEiOiAib3JnLmdub21lLnNoZWxsLmV4dGVuc2lvbnMucGFubyIsCiAgInVybCI6ICJodHRwczovL2dpdGh1Yi5jb20vb2FlL2dub21lLXNoZWxsLXBhbm8iLAogICJzaGVsbC12ZXJzaW9uIjogWyI0NSIsICI0NiJdCn0=" | base64 --decode > $out/metadata.json
    '';
  };
  patches = [
    (substituteAll {
      src = ./pano_at_elhan.io.patch;
      inherit gsound libgda6;
    })
  ];

  nativeBuildInputs = [ buildPackages.glib ];

  buildPhase = ''
    runHook preBuild
    if [ -d schemas ]; then
      glib-compile-schemas --strict schemas
    fi
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r -T . $out/share/gnome-shell/extensions/pano@elhan.io
    runHook postInstall
  '';
  meta = {
    description = "Next-gen Clipboard manager for Gnome Shell";
    homepage = "https://github.com/oae/gnome-shell-pano";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
  passthru = {
    extensionPortalSlug = "pano";
    extensionUuid = "pano@elhan.io";
  };
}
