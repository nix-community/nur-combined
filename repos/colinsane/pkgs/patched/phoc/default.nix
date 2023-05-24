{ fetchpatch, phoc }:
phoc.overrideAttrs (super: {
  patches = super.patches or [] ++ [
    (fetchpatch {
      # this patch fixes some screen-blanking issues.
      # not 100% necessary, but does give a better experience.
      url = "https://gitlab.gnome.org/World/Phosh/phoc/-/merge_requests/428.diff";
      hash = "sha256-XaSpcjtAFbGpqSLOUvjFU84TRmjKhL0NPIDvEK4VUD4=";
    })
  ];
})
