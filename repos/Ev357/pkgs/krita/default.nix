{
  symlinkJoin,
  krita-plugin-gmic,
  binaryPlugins ? [
    krita-plugin-gmic
  ],
  callPackage,
  unwrapped ? callPackage ../krita-unwrapped {},
}:
symlinkJoin {
  pname = "krita";
  inherit
    (unwrapped)
    version
    buildInputs
    nativeBuildInputs
    meta
    ;

  paths = [unwrapped] ++ binaryPlugins;

  postBuild =
    # bash
    ''
      wrapQtApp "$out/bin/krita" \
        --prefix PYTHONPATH : "$PYTHONPATH" \
        --set KRITA_PLUGIN_PATH "$out/lib/kritaplugins"
    '';

  passthru = {
    inherit unwrapped binaryPlugins;
  };
}
