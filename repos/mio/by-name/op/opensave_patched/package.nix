{ opensave }:

opensave.overrideAttrs (old: {
  pname = "opensave-patched";

  patches = (old.patches or [ ]) ++ [
    ./recomp-saves.patch
    ./webkit-gpu-policy.patch
  ];

  # The upstream suite is the long-running daemon/e2e suite the base package
  # excludes. Run only the scanner tests here: they cover the added presets
  # and need neither a desktop nor network access.
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    go test ./internal/presets
    runHook postCheck
  '';

  meta = (old.meta or { }) // {
    description = "Peer-to-peer game save sync (patched for nurpkgs recompilation ports)";
    longDescription = ''
      OpenSave with save autodetection for the static-recompilation games
      packaged in this repository: ACNHRecomp, DOAXVB Recomp, Grand Theft Auto
      2 Recompiled, Pinyon Shift, Recompia, Skate3Recomp/Skate3Recomp+, the
      SpeedBreaker Carbon port, and Takedawn. It also asks WebKitGTK for its
      non-deprecated hardware-acceleration policy instead of the ON_DEMAND
      value that logs a warning on every launch.
    '';
  };
})
