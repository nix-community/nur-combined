{ cozy, fetchpatch }: cozy.overrideAttrs (upstream: {
  patches = upstream.patches or [] ++ [
    (fetchpatch {
      # 2023/03/29: Fix "invalid version" crash on startup
      url = "https://github.com/geigi/cozy/pull/762.diff";
      hash = "sha256-Wk03NGVU7OsQu3AGILtRsQX2r+wPOt5U85cOWu4q6Uo=";
    })
  ];
  passthru = (upstream.passthru or {}) // { upstream.cozy = cozy; };
})
