finalPkgs: prev: {
  cups-dymo = prev.cups-dymo.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./add-30572.patch ];
  });
}
