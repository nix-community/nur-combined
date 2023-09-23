{ cozy, fetchpatch }: cozy.overrideAttrs (upstream: {
  patches = upstream.patches or [] ++ [
    (fetchpatch {
      # 2023/03/29: Fix "invalid version" crash on startup
      # - 2023/09/15: still not merged upstream
      url = "https://github.com/geigi/cozy/pull/762.diff";
      hash = "sha256-Wk03NGVU7OsQu3AGILtRsQX2r+wPOt5U85cOWu4q6Uo=";
    })
  ];
  postPatch = (upstream.postPatch or "") + ''
    # disable all reporting.
    # this can be done via the settings, but that's troublesome and easy to forget.
    # specifically, i don't want moby to be making these network requests several times per hour
    # while it might be roaming or trying to put the RF to sleep.
    substituteInPlace cozy/application_settings.py \
      --replace 'self._settings.get_int("report-level")' '0'
  '';
  passthru = (upstream.passthru or {}) // { upstream.cozy = cozy; };
})
