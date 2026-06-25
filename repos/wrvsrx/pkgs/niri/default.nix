{
  niri,
  fetchpatch,
}:
niri.overrideAttrs (
  finalAttrs: oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://github.com/wrvsrx/niri/compare/tag_session-env-flag%5E..tag_session-env-flag.patch";
        hash = "sha256-EDZZdFpbgPcIBJYU/L9tqXctGk1dboZbErEt0GIKhVw=";
      })
      (fetchpatch {
        url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_4~19..tag_support-shm-sharing_4.patch";
        hash = "sha256-mfX0CVJWSFb/Hr1lDvlggphpXc2PI6C5CBa+aGwkVIM=";
      })
      (fetchpatch {
        url = "https://github.com/wrvsrx/niri/compare/tag_virtual-outputs~8..tag_virtual-outputs.diff";
        hash = "sha256-pNcBT+sY4vsmMX8GpbpqUwq8/6EOyOnas6/aQ8XYGOo=";
      })
    ];
  }
)
