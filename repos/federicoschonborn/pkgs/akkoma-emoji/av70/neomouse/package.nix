{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    srcs = {
      neomouse = fetchzip {
        name = "neomouse";
        url = "https://git.gay/av70/neomouse/releases/download/${finalAttrs.version}/neomouse.zip";
        stripRoot = false;
        hash = "sha256-4C2zu+tkBWikbxpM4VDahezmg+EqBnOytt7cIQAfSQI=";
      };

      additional = fetchzip {
        name = "additionalSrc";
        url = "https://git.gay/av70/neomouse/releases/download/${finalAttrs.version}/neomouse-additional.zip";
        stripRoot = false;
        hash = "sha256-Pe62g/13m4X93eLllhOZ8bunMMqKtNp0shJzmhg6tpU=";
      };

      spinny-mouse = fetchzip {
        name = "spinnyMouseSrc";
        url = "https://git.gay/av70/neomouse/releases/download/${finalAttrs.version}/spinny-mouse.zip";
        stripRoot = false;
        hash = "sha256-Fl4qxJL+o++3NfW+2mSjsEAEYO4/CkwE9ZS5T0RY7LU=";
      };
    };
  in
  {
    pname = "av70-neomouse";
    version = "1.2";

    outputs = [
      "out"
      "additional"
      "spinnyMouse"
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      cp -r ${srcs.neomouse} $out
      cp -r ${srcs.additional} $additional
      cp -r ${srcs.spinny-mouse} $spinnyMouse

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--url"
        "https://git.gay/av70/neomouse"
      ];
    };

    meta = {
      description = "There are mice";
      homepage = "https://git.gay/av70/neomouse";
      license = lib.licenses.cc-by-nc-sa-40;
      platforms = lib.platforms.all;
      maintainers = with lib.maintainers; [ federicoschonborn ];
    };
  }
)
