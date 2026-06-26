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
        # Squashed .diff (not per-commit .patch): the series creates
        # src/tests/virtual_output.rs and modifies it in a later commit, which GNU patch
        # mishandles as a format-patch series. The squashed diff lists the file once.
        url = "https://github.com/wrvsrx/niri/compare/tag_virtual-outputs_2~9..tag_virtual-outputs_2.diff";
        hash = "sha256-CJxNzSS++fL1pBwA+DtD/QKAj+mn25Daw3IbLly77SU=";
      })
    ];
  }
)
