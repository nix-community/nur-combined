{ niri, fetchpatch }:
niri.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/niri/compare/tag_no-import-environment%5E...tag_no-import-environment.patch";
      hash = "sha256-khXqHollR9qw3U5lNSdg51OmHoVc1OJSfvpqilJhwWA=";
    })
  ];
})
