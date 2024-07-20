{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    srcs = {
      neomouse = fetchzip {
        name = "neomouse";
        url = "https://git.gay/av70/neomouse/releases/download/${finalAttrs.version}/neomouse-${finalAttrs.version}.zip";
        stripRoot = false;
        hash = "sha256-2ru+YOJc0DVOi0VX0WJw/AWmZrKzGR5qiUrlNK7QM9w=";
      };

      additional = fetchzip {
        name = "additionalSrc";
        url = "https://git.gay/av70/neomouse/releases/download/${finalAttrs.version}/neomouse-additional.zip";
        stripRoot = false;
        hash = "sha256-fKycKcFa/f7Tigmswz8MLi8UP1KLF/34pnZmgOajshA=";
      };

      spinny-mouse = fetchzip {
        name = "spinnyMouseSrc";
        url = "https://git.gay/av70/neomouse/releases/download/${finalAttrs.version}/spinny-mouse.zip";
        stripRoot = false;
        hash = "sha256-ZyJ5T608YmNx2l6/sXVhoHkhjTd5qngClNtVsCGVQn0=";
      };
    };
  in
  {
    pname = "av70-neomouse";
    version = "1.1-1";

    outputs = [
      "out"
      "additional"
      "spinnyMouse"
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out $additional $spinnyMouse
      cp -r ${srcs.neomouse}/{meta.json,*.{gif,png}} $out
      cp -r ${srcs.additional}/{meta.json,*.png} $additional
      cp -r ${srcs.spinny-mouse}/{meta.json,*.gif} $spinnyMouse

      runHook postInstall
    '';

    meta = {
      description = "There are mice";
      homepage = "https://git.gay/av70/neomouse";
      license = lib.licenses.cc-by-nc-sa-40;
      platforms = lib.platforms.all;
      maintainers = with lib.maintainers; [ federicoschonborn ];
    };
  }
)
