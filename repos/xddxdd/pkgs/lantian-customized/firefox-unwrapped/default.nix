{
  firefox-unwrapped,
  lib,
  sources,
}:
firefox-unwrapped.overrideAttrs (old: {
  version = lib.removePrefix "v" (lib.last (lib.splitString "/" sources.invisible-firefox.version));
  inherit (sources.invisible-firefox) src;

  # Skip macOS specific patches
  prePatch = (old.prePatch or "") + ''
    local -a patchesArray
    concatTo patchesArray patches
    for i in "''${!patchesArray[@]}"; do
      if grep "/macos_fake_sdk/" "''${patchesArray[i]}" >/dev/null 2>&1; then
        echo "skipping patch ''${patchesArray[i]}"
        unset 'patchesArray[i]'
      fi
    done
    patches="''${patchesArray[@]}"
    echo "Final patches: $patches"
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
