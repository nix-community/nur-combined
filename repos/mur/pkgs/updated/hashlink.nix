{ hashlink, lib, fetchFromGitHub }:
hashlink.overrideAttrs (finalAttrs: previousAttrs: {
    version = "1.14";
    src = fetchFromGitHub {
      owner = "HaxeFoundation";
      repo = "hashlink";
      rev = finalAttrs.version;
      sha256 = "sha256-rXw56zoFpLMzz8U3RHWGBF0dUFCUTjXShUEhzp2Qc5g="; 
    };

    postInstall = let
      haxelibPath =
        "$out/lib/haxe/hashlink/${lib.replaceStrings [ "." ] [ "," ] finalAttrs.version}";
    in ''
      mkdir -p "${haxelibPath}"
      echo -n "${finalAttrs.version}" > "${haxelibPath}/../.current"
      cp -r other/haxelib/* "${haxelibPath}"
    '';
})
