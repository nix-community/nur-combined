{ librime, lib, newScope }:

lib.makeScope newScope (self:
let
  inherit (self) callPackage;
  hooks = callPackage ./hooks { };
in
{
  inherit librime;
  withRimeDeps = callPackage ./with-rime-deps { };
  inherit (hooks) rimeDataBuildHook;
  rime-bopomofo = callPackage ./rime-bopomofo { };
  rime-cangjie = callPackage ./rime-cangjie { };
  rime-cantonese = callPackage ./rime-cantonese { };
  rime-double-pinyin = callPackage ./rime-double-pinyin { };
  rime-emoji = callPackage ./rime-emoji { };
  rime-essay = callPackage ./rime-essay { };
  rime-ice = callPackage ./rime-ice { };
  rime-loengfan = callPackage ./rime-loengfan { };
  rime-luna-pinyin = callPackage ./rime-luna-pinyin { };
  rime-pinyin-simp = callPackage ./rime-pinyin-simp { };
  rime-prelude = callPackage ./rime-prelude { };
  rime-quick = callPackage ./rime-quick { };
  rime-stroke = callPackage ./rime-stroke { };
  rime-terra-pinyin = callPackage ./rime-terra-pinyin { };
  rime-wubi = callPackage ./rime-wubi { };
  rime-wugniu = callPackage ./rime-wugniu { };
})
