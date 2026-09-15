{
  niri,
  fetchpatch,
}:
niri.overrideAttrs (
  finalAttrs: oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://github.com/wrvsrx/niri/compare/tag_session-env-flag^..tag_session-env-flag.patch";
        hash = "sha256-EDZZdFpbgPcIBJYU/L9tqXctGk1dboZbErEt0GIKhVw=";
      })
      (fetchpatch {
        # https://github.com/niri-wm/niri/pull/1791
        url = "https://github.com/niri-wm/niri/compare/3871a3cd76a4168b2dc7c3da880fbe2702bd8900~11..3871a3cd76a4168b2dc7c3da880fbe2702bd8900.diff";
        hash = "sha256-4L4PS4HenyXlYkuWG8n6L5nKOCiw06ts1gD+tGBqy5Y=";
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
