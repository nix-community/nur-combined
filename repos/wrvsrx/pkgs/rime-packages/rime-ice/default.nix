{ source }:
self:
{
rime-ice-all = self.callPackage ./rime-ice-all { inherit source; };
rime-ice-flypy = self.callPackage ./rime-ice-flypy { inherit source; };
rime-ice-lua = self.callPackage ./rime-ice-lua { inherit source; };
rime-ice-common = self.callPackage ./rime-ice-common { inherit source; };
rime-ice-opencc = self.callPackage ./rime-ice-opencc { inherit source; };
rime-ice-pinyin-dict = self.callPackage ./rime-ice-pinyin-dict { inherit source; };
rime-ice-cn_dicts = self.callPackage ./rime-ice-cn_dicts { inherit source; };
rime-ice-melt_eng = self.callPackage ./rime-ice-melt_eng { inherit source; };
rime-ice-en_dicts = self.callPackage ./rime-ice-en_dicts { inherit source; };
rime-ice-radical_pinyin = self.callPackage ./rime-ice-radical_pinyin { inherit source; };

}
