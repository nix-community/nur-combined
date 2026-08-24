{
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
  dpkg,
  alsa-lib,
  freetype,
  libGL,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      product,
      meta ? { },
      ...
    }:
    {
      nativeBuildInputs = [
        autoPatchelfHook
        dpkg
      ];

      buildInputs = [
        alsa-lib
        freetype
        libGL
      ];

      unpackPhase = ''
        mkdir -p root
        dpkg-deb --fsys-tarfile $src | tar --extract --directory=root
      '';

      buildPhase = ''
        runHook preBuild

        cp -r root/usr $out

        runHook postBuild
      '';

      passthru.updateScript = writeScript "update-tonelib-${finalAttrs.pname}" ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p curl pcre2 common-updater-scripts

        version="$(curl -s "https://tonelib.net/downloads.html" | pcre2grep -Mo1 '${product}.+\n.+Version: (\d+.\d+.\d+)')"
        update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
      '';

      meta = {
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
