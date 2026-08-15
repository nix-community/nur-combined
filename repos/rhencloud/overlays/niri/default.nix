_final: prev: {
  niri = prev.niri.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./mouse-passthrough.patch
      ./pin.patch
    ];
  });
}
