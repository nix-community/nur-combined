{
  firefox-unwrapped,
  lib,
  sources,
}:
firefox-unwrapped.overrideAttrs (old: {
  inherit (sources.invisible-firefox) version src;

  patchPhase = ''
    runHook prePatch

    local -a patchesArray
    concatTo patchesArray patches
    for p in "''${patchesArray[@]}"; do
      if grep -q "/macos_fake_sdk/" "$p" 2>/dev/null; then
        echo "skipping patch $p"
      else
        echo "applying patch $p"
        patch -p1 < "$p"
      fi
    done

    runHook postPatch
  '';

  postPatch = (old.postPatch or "") + ''
    # Remove mozconfig changes causing build failure
    rm -f .mozconfig
  '';

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Firefox with anti fingerprinting modifications";
  };
})
