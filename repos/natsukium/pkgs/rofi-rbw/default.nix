{ fetchpatch, rofi-rbw }:
rofi-rbw.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      name = "fuzzel-support.patch";
      url = "https://github.com/natsukium/rofi-rbw/commit/9db101fec3941678f725c9ba7ddc394afef5a089.patch";
      includes = [
        "src/rofi_rbw/selector/fuzzel.py"
        "src/rofi_rbw/selector/selector.py"
      ];
      hash = "sha256-TnKFJDr9PSe1gk1wzYFBNO9xDxKxPyw4LtE9K3e+vk4=";
    })
  ];

  meta = oldAttrs.meta // {
    description = "Patched version of rofi-rbw with fuzzel support";
    homepage = "https://github.com/natsukium/rofi-rbw";
  };
})
