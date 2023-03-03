{ lib, newScope }:

lib.makeScope newScope (self:
let
  inherit (self) callPackage;
in
{
  rime-bopomofo = callPackage ./rime-bopomofo { };
  rime-cangjie = callPackage ./rime-cangjie { };
  rime-essay = callPackage ./rime-essay { };
  rime-ice = callPackage ./rime-ice { };
  rime-luna-pinyin = callPackage ./rime-luna-pinyin { };
  rime-prelude = callPackage ./rime-prelude { };
  rime-stroke = callPackage ./rime-stroke { };
  rime-terra-pinyin = callPackage ./rime-terra-pinyin { };
})
