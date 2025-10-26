{ gnuradio, boost181, ... }@args:

# Recent updates upgraded boost to a version which deprecated a lot of things causing a lot of breakage
# Since boost versions have to match, override it to the last known working version
gnuradio.override ({
  unwrapped = (gnuradio.unwrapped.override {
    boost = boost181;
  }).overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./fix-boost-format-formatter.patch
    ];
    postPatch = (old.postPatch or "") + ''
      # Disable Python bindings hash check since we patched logger.h
      substituteInPlace cmake/Modules/GrPybind.cmake \
        --replace-fail 'message(FATAL_ERROR' \
                       'message(WARNING'
    '';
  });
} // (removeAttrs args ["boost181" "gnuradio"] ))  