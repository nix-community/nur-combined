{
  stdenvNoCC,
  lib,
  fetchurl,
  variants ? ["ja-jp" "zh-cn"],
}: let
  # https://blog.amarea.cn/archives/genshin-windows-cn.html
  fetchGenshin = {
    version ? "4.5.0",
    path,
    ...
  } @ args:
    fetchurl (removeAttrs args ["version" "path"]
      // {
        url =
          if (builtins.compareVersions version "2.3.0" != -1)
          then "https://autopatchcn.yuanshen.com/client_app/download/pc_zip/${map.${version}}/ScatteredFiles/${path}"
          else "https://autopatchcn.yuanshen.com/client_app/pc_mihoyo/${map.${version}}/${version}/${path}";
      });

  map = {
    "4.5.0" = "20240301202812_kIdgwLMrsEqWTonu";
    "4.4.0" = "20240119183624_htNiHcgyl05jgCo9";
    "4.3.0" = "20231208190455_Hej85Uh2vkx38Tia";
    "4.2.0" = "20231030130954_PsW6Fr19EHxBCeKn";
    "4.1.0" = "20230916101643_AgUJUVY76sv5uqeS";
    "4.0.1" = "20230821151113_kRtiSWdMasWNheoV";
    "4.0.0" = "20230804185703_R1La3H9xIH1hBiHJ";
    "3.8.0" = "20230625120029_C0NLGkC0fxSaNKnu";
    "3.7.0" = "20230513200250_hFVOC1wXPDVnzH87";
    "3.6.0" = "20230331200338_Sn5XSSFSqcIjAQL1";
    "3.5.0" = "20230220120841_NrIMna0roQkFHA3c";
    "3.4.0" = "20230109134623_pLhUB4LFubdudxQa"; # invalid?
    "3.3.0" = "20221128113626_LSJsjaUDgixXmWnd";
    "3.2.0" = "20221024103540_fp3L3cHoDpo9eNeT"; # invalid?
    "3.1.0" = "20220917165328_rVH9t4OWduSD75ye";
    "3.0.0" = "20220815143702_i3RDKzdbDWGYYfZZ";
    "2.8.0" = "20220625003700_3RiwWggLSQ14iInN";
    "2.7.0" = "20220510122739_htkJy9BIys9tCMHu";
    "2.6.0" = "20220318210005_l9zBcCngXHqIrxpk";
    "2.5.0" = "20220125104630_obObq2oqPuPFT2Zt";
    "2.4.0" = "20211225041652_jkpmdQVLf6h0xFBk";
    "2.3.0" = "20211117173857_8JkfDHNPmqKi67qR";
    "2.2.0" = "20211013_a336065295309dbe";
    "2.1.0" = "20210901_859f700f6ec7a8a3";
    "2.0.0" = "20210721_3aacc245ccfe47c7";
    "1.6.0" = "20210609_cda4068353f840c3";
  };
in
  # the only difference between "ja-jp" and "zh-cn" is the Kanji/Hanzi part, due to the stupid Han unification
  # https://en.wikipedia.org/wiki/Han_unification
  assert lib.asserts.assertEachOneOf "hanyi-wenhei-genshin: `variants`" variants ["ja-jp" "zh-cn"];
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "hanyi-wenhei-genshin";
      version = "4.5.0";

      srcs = [
        (lib.optional (builtins.elem "ja-jp" variants) (fetchGenshin {
          inherit (finalAttrs) version;
          path = "YuanShen_Data/StreamingAssets/MiHoYoSDKRes/HttpServerResources/font/ja-jp.ttf";
          hash = "sha256-U3Cz7Ly+6VvsMifr8WMuJDx+Kdxou090qgsfj2xK/DI=";
        }))
        (lib.optional (builtins.elem "zh-cn" variants) (fetchGenshin {
          inherit (finalAttrs) version;
          path = "YuanShen_Data/StreamingAssets/MiHoYoSDKRes/HttpServerResources/font/zh-cn.ttf";
          hash = "sha256-4l6+jCxIk5HMAM64QeXCkdwme+HBLNxGXvPVRNj+OlE=";
        }))
      ];

      # found on HoYoWiki (https://wiki.hoyolab.com/pc/genshin/home)
      # srcs = [
      #   (fetchurl {
      #     url = "https://wiki.hoyolab.com/fonts/genshin/Default_SC.ttf";
      #     hash = "sha256-H7O2+rCpIULRqrIYRNswFeXNhsnd6Uvjv+naJBzq9hY=";
      #   })
      #   (fetchurl {
      #     url = "https://wiki.hoyolab.com/fonts/genshin/Default_JP.ttf";
      #     hash = "sha256-x+aK+iIB0IwHlNUjIpznEZ7tyHpnmNSIKD7kiYDXkRs=";
      #   })
      # ];

      # found on Genshin Cloud Gaming (https://ys.mihoyo.com/cloud/)
      # srcs = [
      #   (fetchurl {
      #     url = "https://webstatic.mihoyo.com/common/clgm-static/ys/fonts/ja-jp.ttf";
      #     hash = "sha256-5Yn722yp6LRyNCEHarlWDFK0IieaGjXylTdWwZcm0Ig=";
      #   })
      #   (fetchurl {
      #     url = "https://webstatic.mihoyo.com/common/clgm-static/ys/fonts/zh-cn.ttf";
      #     hash = "sha256-wxMg6z15zDKGUArweW7DkO1C2GImnFdVqvh0xud1CDM=";
      #   })
      # ];

      sourceRoot = ".";
      unpackCmd = ''
        ttfName=$(basename $(stripHash $curSrc))
        cp $curSrc ./$ttfName
      '';

      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      doCheck = false;
      dontFixup = true;

      installPhase = ''
        runHook preInstall

        install -Dm644 -t $out/share/fonts/truetype/ *.ttf

        runHook postInstall
      '';

      meta = {
        description = "Han Yi Wen Hei (汉仪文黑) font, modified by miHoYo";
        homepage = "https://www.hanyi.com.cn/productdetail?id=987";
        license = lib.licenses.unfree;
      };
    })
