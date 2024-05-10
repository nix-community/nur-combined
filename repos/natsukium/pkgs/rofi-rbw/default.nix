{ fetchpatch, rofi-rbw }:
rofi-rbw.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      name = "fuzzel-support.patch";
      url = "https://github.com/natsukium/rofi-rbw/commit/12d53a06c8963b01f7f2b8b7728f514525050bc9.patch";
      includes = [
        "src/rofi_rbw/selector/fuzzel.py"
        "src/rofi_rbw/selector/selector.py"
      ];
      hash = "sha256-tb+lgsv5BRrh3tnHayKxzVASLcc4I+IaCaywMe9U5qk=";
    })
  ];

  meta = oldAttrs.meta // {
    description = "Patched version of rofi-rbw with fuzzel support";
    homepage = "https://github.com/natsukium/rofi-rbw";
  };
})
