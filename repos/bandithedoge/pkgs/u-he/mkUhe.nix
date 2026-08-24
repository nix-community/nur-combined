{
  fetchzip,
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
  glib,
  gtk3,
  libxcb,
  libxcb-keysyms,
  libxcb-util,
  u-he,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      product,
      hash,
      updateName ? product,
      extension ? "tar.xz",
      clap ? true,
      nativeBuildInputs ? [ ],
      buildInputs ? [ ],
      meta ? { },
      ...
    }:
    {
      src = fetchzip {
        url = "https://uhe-dl.b-cdn.net/releases/${updateName}_${finalAttrs.version}_Linux.${extension}";
        inherit hash;
      };

      nativeBuildInputs = [
        autoPatchelfHook
      ]
      ++ nativeBuildInputs;

      buildInputs = [
        glib
        gtk3
        libxcb
        libxcb-keysyms
        libxcb-util
      ]
      ++ buildInputs;

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/libexec
        cp -r ${product} $out/libexec/${product}
        for p in $out/libexec/${product}/Presets/*; do
          mkdir -p "$p/MIDI Programs"
        done

        # adapted from https://git.sr.ht/~raphi/elf-replace-symbol/tree/master/item/libfprint2-tod1-broadcom/default.nix
        substitute ${./wrapper.c} wrapper.c \
          --subst-var-by store_path $out/libexec/${product}
        cc -fPIC -shared -O3 wrapper.c -o $out/libexec/${product}/snprintf_wrapper_${product}.so

        ${lib.getExe u-he.patchelf-raphi} \
          --replace-symbol snprintf snprintf_wrapper \
          --add-needed snprintf_wrapper_${product}.so \
          $out/libexec/${product}/${product}.64.so

        mkdir -p $out/lib/vst
        ln -s $out/libexec/${product}/${product}.64.so $out/lib/vst/${product}.64.so

        mkdir -p $out/lib/vst3/${product}.vst3/Contents/{x86_64-linux,Resources/Documentation}
        ln -s $out/libexec/${product}/${product}.64.so $out/lib/vst3/${product}.vst3/Contents/x86_64-linux/${product}.so
        ln -s $out/libexec/${product}/*.pdf $out/lib/vst3/${product}.vst3/Contents/Resources/Documentation/
      ''
      + (lib.optionalString clap ''
        mkdir -p $out/lib/clap
        ln -s $out/libexec/${product}/${product}.64.so $out/lib/clap/${product}.64.clap
      '')
      + ''
        runHook postBuild
      '';

      passthru = {
        inherit product;
        updateScript = writeScript "update-uhe-${finalAttrs.pname}" ''
          #!/usr/bin/env nix-shell
          #!nix-shell -i bash -p curl pcre2 common-updater-scripts

          version="$(curl -s "https://uhe-dl.b-cdn.net/releases/" | pcre2grep -o1 '${updateName}_(\w+)_Linux' | head -1)"
          update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
        '';
      };

      meta = {
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
