{
  fetchzip,
  lib,
  stdenv,
  writeScript,

  alsa-lib,
  autoPatchelfHook,
  libxkbcommon,
  lilv,
  vulkan-loader,
  wayland,
}:
let
  version = "0.10.8";
  sources = {
    aarch64 = fetchzip {
      url = "https://github.com/mlm-games/yadaw/releases/download/v${version}/yadaw-${version}-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-bbYR1uFX2ijQX8uKdfSaIE5RdRPFTaObrxFyh30upjc=";
    };
    x86_64 = fetchzip {
      url = "https://github.com/mlm-games/yadaw/releases/download/v${version}/yadaw-${version}-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-0kSbpol0g2fIQzgMFqqv80oJOVboOCBgFFXFY1u3j10=";
    };
  };
in
stdenv.mkDerivation {
  pname = "yadaw-bin";
  inherit version;
  src = if stdenv.targetPlatform.isAarch64 then sources.aarch64 else sources.x86_64;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    libxkbcommon
    lilv
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    patchelf \
      --add-needed libvulkan.so \
      --add-needed libwayland-client.so \
      --add-needed libxkbcommon.so \
      yadaw
    cp yadaw $out/bin

    runHook postBuild
  '';

  passthru = sources // {
    updateScript = writeScript "update-yadaw-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/mlm-games/yadaw/releases/latest | jq -r '.tag_name | scan("v(.*)") | .[0]')"
      ${lib.concatMapStringsSep "\n" (
        system:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${system} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "Sfx creation tool and midi player that doesn't crash often";
    homepage = "https://github.com/mlm-games/yadaw";
    license = lib.licenses.agpl3Plus;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "yadaw";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
