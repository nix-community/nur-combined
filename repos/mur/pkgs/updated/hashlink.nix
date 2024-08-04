{ hashlink, lib, fetchFromGitHub }:
hashlink.overrideAttrs (finalAttrs: previousAttrs: {
    version = "1.4.0";
    src = fetchFromGitHub {
      owner = "HaxeFoundation";
      repo = "hashlink";
      rev = finalAttrs.version;
      sha256 = lib.fakeHash;
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
