{
  stdenvNoCC,
  lib,
  fetchurl,
  variant ? "ja-jp",
}:
# the only difference between "ja-jp" and "zh-cn" is the Kanji/Hanzi part, due to the stupid Han unification
# https://en.wikipedia.org/wiki/Han_unification
assert (lib.asserts.assertMsg (variant == "ja-jp" || variant == "zh-cn") ''hanyi-wenhei-genshin: `variant` must be "ja-jp" or "zh-cn"'');
  stdenvNoCC.mkDerivation {
    pname = "hanyi-wenhei-genshin";
    version = "1.00"; # from font metadata

    # found on Genshin Cloud Gaming (https://ys.mihoyo.com/cloud/)
    src = fetchurl {
      url = "https://webstatic.mihoyo.com/common/clgm-static/ys/fonts/${variant}.ttf";
      hash =
        {
          ja-jp = "sha256-5Yn722yp6LRyNCEHarlWDFK0IieaGjXylTdWwZcm0Ig=";
          zh-cn = "sha256-wxMg6z15zDKGUArweW7DkO1C2GImnFdVqvh0xud1CDM=";
        }
        .${variant};
    };

    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    doCheck = false;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      install -Dm644 $src $out/share/fonts/truetype/$(stripHash $src)

      runHook postInstall
    '';

    meta = {
      description = "Han Yi Wen Hei (汉仪文黑) font, modified by miHoYo";
      homepage = "https://www.hanyi.com.cn/productdetail?id=987";
      license = lib.licenses.unfree;
    };
  }
