{
  fetchurl,
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
  juceCmakeHook,
}:
let
  version = "2.5.4";
  sources = {
    standalone = fetchurl {
      url = "https://github.com/mzuther/Squeezer/releases/download/v${version}/squeezer-linux64-standalone_${version}.tar.gz";
      sha256 = "sha256-M0Q95PrL/91r9xA2T88yzV/EpmwIWdC+7JylBpPuDLs=";
    };
    vst2 = fetchurl {
      url = "https://github.com/mzuther/Squeezer/releases/download/v${version}/squeezer-linux64-vst2_${version}.tar.gz";
      sha256 = "sha256-o5b+jg27gyt6G3duatijdS/ZIObkQl/sMtZLHvt+vzs=";
    };
  };
in
stdenv.mkDerivation rec {
  pname = "squeezer-bin";
  inherit version;
  srcs = builtins.attrValues sources;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/vst}

    cp squeezer-linux64-vst2_${version}/*.so $out/lib/vst
    cp -r squeezer-linux64-vst2_${version}/squeezer $out/lib/vst

    cp \
      squeezer-linux64-standalone_${version}/squeezer_mono_x64 \
      squeezer-linux64-standalone_${version}/squeezer_stereo_x64 \
      $out/bin
    cp -r squeezer-linux64-standalone_${version}/squeezer $out/bin

    runHook postBuild
  '';

  passthru = sources // {
    updateScript = writeScript "update-squeezer-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/mzuther/Squeezer/releases/latest \
        | jq -r '.tag_name | scan("v(.*)") | .[0]')"
      ${lib.concatMapStringsSep "\n" (
        format:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${format} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "Flexible general-purpose audio compressor with a touch of citrus";
    homepage = "https://github.com/mzuther/Squeezer";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "squeezer";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
