{
  lib,
  stdenvNoCC,
  fetchurl,
  type ? "ttf",
}:
assert lib.assertOneOf "hanyi-wenhei: `type`" type ["ttf" "otf"];
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "hanyi-wenhei";
    version = "5.00";

    srcs = let
      fetchFont = weight: hash: (fetchurl {
        inherit hash;
        url = "https://hellofonts.oss-cn-beijing.aliyuncs.com/汉仪文黑/${finalAttrs.version}/HYWenHei-${weight}.${type}";
      });
    in
      {
        ttf = [
          (fetchFont "35W" "sha256-zIk7znYizEX4+ocd2jNkOgvb0khdBELF7H1Ecy7/ltg=")
          (fetchFont "45W" "sha256-VYCbj+LIT4/XoSQJOjA18pivT2I0wsT87hdW8SnOsXs=")
          (fetchFont "55W" "sha256-lAnb5ufMtz9YKi2w3Y2QJZDGGczfT1maR+K/3y31PlM=")
          (fetchFont "65W" "sha256-qTxdGNX+tMj5wsZpd0LBxUtBosc1VPe2aMUsbniMNNA=")
          (fetchFont "75W" "sha256-jwnBSZ8C3tmb9vqO5gSco/T71G0kScg7gTO+aUFPmw4=")
          (fetchFont "85W" "sha256-bE+aoTfdS9wf3OKPC3fOfeT2KD8c9edEAm5Wfs+fw/o=")
        ];
        otf = [
          (fetchFont "35W" "sha256-hnKnc9DkSeyM82Y4muDCXS5GBst5xzmS+ZArMt1bPyc=")
          (fetchFont "45W" "sha256-AIsuBqq4Ea1/tA42yg0udvBCa6yl2pPBZgZLX56AThU=")
          (fetchFont "55W" "sha256-M1JPUu5r2eDnr9VHZL2Beu5n5wybWqLMBPqb/6dC4RU=")
          (fetchFont "65W" "sha256-7t9PFucRfLTOqSFVICV7Qg540kOM3gj2R4nydpO3Mws=")
          (fetchFont "75W" "sha256-L4iPd9AvMS53C35lSBLvzf8RjGOdI2iXH+08Ksi8RU4=")
          (fetchFont "85W" "sha256-COzaRqdqO7vgO2IEKRko3ck9ZOdm7/iwOfbe72UATzE=")
        ];
      }
      .${type};

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

    installPhase = let
      type' =
        {
          ttf = "truetype";
          otf = "opentype";
        }
        .${type};
    in ''
      runHook preInstall

      install -Dm644 -t $out/share/fonts/${type'}/ HYWenHei-*.${type}

      runHook postInstall
    '';

    meta = {
      description = "Han Yi Wen Hei (汉仪文黑) font";

      # ChatGPT translated from the official description
      # Original:
      # 汉仪文黑，以黑体为基础，保留黑体方而正的结构，融入楷体和圆体的部分特征，
      # 文以化黑、以柔化方。不同于常规黑体，这款字体更为文雅、生动、柔和。
      # 汉仪文黑以完整的家族呈现，包含35/45/55/65/75/85共计6个字重，
      # 可以满足全面的排版需求，传达了正式而友好的气质，适合于广泛的应用场景，
      # 特别适合于屏显环境的应用要求。
      descriptionLong = ''
        Han Yi Wen Hei is based on Heiti (黑体) with a structure that retains the squareness of Heiti characters while incorporating some features of Kai (楷体) and Yuan (圆体) fonts. It softens the squareness and stiff appearance of traditional Heiti, resulting in a more elegant, lively, and gentle font style. Han Yi Wen Hei is presented as a complete font family, including 35/45/55/65/75/85 weights, totaling six font weights. This versatility meets a wide range of typesetting needs, conveying a formal yet friendly demeanor suitable for various applications, especially for screen display environments.
      '';
      homepage = "https://www.hanyi.com.cn/productdetail?id=987";
      license = lib.licenses.unfree; # https://www.hanyi.com.cn/faq-doc-1
    };
  })
