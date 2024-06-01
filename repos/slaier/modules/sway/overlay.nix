final: prev: {
  sway-unwrapped = prev.sway-unwrapped.overrideAttrs (self:
    assert
    (final.lib.versionAtLeast "1.9" self.version);
    let
      fetchpatch = { name, hash }: final.fetchpatch2 {
        inherit name hash;
        url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=sway-im&id=b8434b3ad9e8c6946dbf7b14b0f7ef5679452b94";
      };
    in
    {
      patches = self.patches ++ [
        (fetchpatch {
          name = "0001-text_input-Implement-input-method-popups.patch";
          hash = "sha256-aO21HgHVccD8vOlffcenSAn2spW7iEs0nTa5Tmebe3o=";
        })
        (fetchpatch {
          name = "0002-chore-fractal-scale-handle.patch";
          hash = "sha256-QuV8J0sqh5L9kyYEOTDjWlPNKVb6zolG/cHO+wq2Qa8=";
        })
        (fetchpatch {
          name = "0003-chore-left_pt-on-method-popup.patch";
          hash = "sha256-4zvVbAdxK05UWy+QMsHPHrVBwmO5279GqhYgJUPsCNI=";
        })
      ];
    });
}
