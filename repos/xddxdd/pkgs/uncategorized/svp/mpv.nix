{
  lib,
  mpv-unwrapped,
  ocl-icd,
  vapoursynth,
  ...
}:
let
  libraries = [ ocl-icd ];
in
(mpv-unwrapped.wrapper {
  mpv = (mpv-unwrapped.override { vapoursynthSupport = true; }).overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      # Credit to @xrun1
      # https://github.com/NixOS/nixpkgs/issues/295429
      # https://github.com/xrun1/mpv-svp-fix
      ./xrun1-restore-vf-del-option.patch
    ];
  });
  extraMakeWrapperArgs = [
    # Add paths to required libraries
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    "/run/opengl-driver/lib:${lib.makeLibraryPath libraries}"
  ];
}).overrideAttrs
  (old: {
    meta = old.meta // {
      maintainers = with lib.maintainers; [ xddxdd ];
      inherit (vapoursynth.meta) platforms;
      inherit (mpv-unwrapped.meta) license;
    };
  })
