final: prev:
{
  transgui = prev.transgui.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (final.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/transmission-remote-gui/transgui/pull/1354.patch";
        sha256 = "sha256-Q4DAduqnTtNI0Zw9NIWpE8L0G8RusvPbZ3iW29k7XXA=";
      })
    ];
  });
}
