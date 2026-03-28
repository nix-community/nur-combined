{
  symlinkJoin,
  krita-plugin-gmic,
  binaryPlugins ? [
    krita-plugin-gmic
  ],
  callPackage,
}: let
  krita-unwrapped = callPackage ../krita-unwrapped {};
in
  symlinkJoin {
    pname = "krita";
    inherit
      (krita-unwrapped)
      version
      buildInputs
      nativeBuildInputs
      meta
      ;

    paths = [krita-unwrapped] ++ binaryPlugins;

    postBuild =
      # bash
      ''
        wrapQtApp "$out/bin/krita" \
          --prefix PYTHONPATH : "$PYTHONPATH" \
          --set KRITA_PLUGIN_PATH "$out/lib/kritaplugins"
      '';

    passthru = {
      inherit binaryPlugins;
      unwrapped = krita-unwrapped;
    };
  }
