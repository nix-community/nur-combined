{ modemmanager }: modemmanager.overrideAttrs (upstream: {
  patches = (upstream.patches or []) ++ [
    # don't go into the "fail" state just because we can't figure out if the SIM is unlocked
    ./missing-sim-not-fatal.patch
  ];
})
