final: prev: {
  # backport of nixpkgs 9e5226c5a462; without it the app hangs on the splash screen
  intiface-central =
    if prev.intiface-central.version == "3.0.4+40" then
      prev.intiface-central.overrideAttrs (old: {
        extraWrapProgramArgs =
          "--set FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR ${placeholder "out"}/app/intiface-central/lib "
          + old.extraWrapProgramArgs;
      })
    else
      prev.intiface-central;
}
