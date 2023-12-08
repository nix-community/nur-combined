{
  lib,
  mpv-unwrapped,
  wrapMpv,
  ocl-icd,
  ...
}: let
  libraries = [
    ocl-icd
  ];
in
  wrapMpv
  (mpv-unwrapped.override {
    vapoursynthSupport = true;
  })
  {
    extraMakeWrapperArgs = [
      # Enable MPV socket for SVP to control
      "--add-flags"
      "--input-ipc-server=/tmp/mpvsocket"

      # Add paths to required libraries
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      "/run/opengl-driver/lib:${lib.makeLibraryPath libraries}"
    ];
  }
