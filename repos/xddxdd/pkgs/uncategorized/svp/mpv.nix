{
  lib,
  mpv,
  mpv-unwrapped,
  ocl-icd,
  vapoursynth,
}:
let
  libraries = [ ocl-icd ];
in
(mpv.override {
  mpv-unwrapped = mpv-unwrapped.override { vapoursynthSupport = true; };
  extraMakeWrapperArgs = [
    # Add paths to required libraries
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    "/run/opengl-driver/lib:${lib.makeLibraryPath libraries}"
  ];
}).overrideAttrs
  (old: {
    # symlinkJoin bridges `paths` through passAsFile, which does not survive
    # __structuredAttrs; no symlinks get created and postBuild's rm fails.
    __structuredAttrs = false;
    strictDeps = true;
    meta = old.meta // {
      maintainers = with lib.maintainers; [ xddxdd ];
      inherit (vapoursynth.meta) platforms;
      inherit (mpv-unwrapped.meta) license;
    };
  })
