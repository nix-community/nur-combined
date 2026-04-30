{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tree,
  imagemagick,
  callPackage,
}:
let
  current = lib.trivial.importJSON ./version.json;

  pname = "biu";
  version = current.version;

  sourceMap = {
    x86_64-linux = fetchurl {
      url = "https://github.com/wood3n/biu/releases/download/v${version}/Biu-${version}-linux-x86_64.AppImage";
      hash = current.x86_64-linux-hash;
    };

    aarch64-linux = fetchurl {
      url = "https://github.com/wood3n/biu/releases/download/v${version}/Biu-${version}-linux-arm64.AppImage";
      hash = current.aarch64-linux-hash;
    };
  };

  src = sourceMap.${stdenv.hostPlatform.system};

  appimageContents = appimageTools.extractType2 {
    inherit src pname version;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [
    tree
    makeWrapper
    imagemagick
  ];

  extraInstallCommands = ''
    tree ${appimageContents}

    install -m 444 -D \
      ${appimageContents}/Biu.desktop \
      $out/share/applications/biu.desktop

    for size in 16 24 32 48 64 128 256 512; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      magick convert -background none -resize "$size"x"$size" ${appimageContents}/Biu.png $out/share/icons/hicolor/"$size"x"$size"/apps/Biu.png
    done

    substituteInPlace $out/share/applications/biu.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=biu'

    wrapProgram $out/bin/biu \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--enable-wayland-ime" \
      --add-flags "--disable-gpu"
  '';

  passthru.updateScript =
    let
      versionFile = "pkgs/biu/version.json";
    in
    callPackage ../../utils/update.nix {
      pname = "biu";
      inherit versionFile;
      updateMethod = "none";

      # 使用 lib.getExe 获取 json.nix 生成的可执行脚本路径
      fetchMetaCommand = "${lib.getExe (
        callPackage ../../utils/json.nix {
          preScript = ''
            VERSION=$(curl -sS https://api.github.com/repos/wood3n/biu/releases/latest | jq -r '.tag_name | ltrimstr("v")')

            CURRENT_VERSION=$(jq -r '.version' "${versionFile}" 2>/dev/null || echo "")

            if [ "$VERSION" = "$CURRENT_VERSION" ]; then
              # 必须输出当前内容，以便 update.nix 判断 is_changed
              cat "${versionFile}"
              exit 0
            fi

            URL_X86="https://github.com/wood3n/biu/releases/download/v$VERSION/Biu-$VERSION-linux-x86_64.AppImage"
            URL_ARM="https://github.com/wood3n/biu/releases/download/v$VERSION/Biu-$VERSION-linux-arm64.AppImage"

            echo "[*] Prefetching x86_64 hash..." >&2
            HASH_X86=$(nix-prefetch-url "$URL_X86" --type sha256 | xargs nix-hash --to-sri --type sha256)

            echo "[*] Prefetching aarch64 hash..." >&2
            HASH_ARM=$(nix-prefetch-url "$URL_ARM" --type sha256 | xargs nix-hash --to-sri --type sha256)
          '';

          commands = {
            version = "echo $VERSION";
            "x86_64-linux-hash" = "echo $HASH_X86";
            "aarch64-linux-hash" = "echo $HASH_ARM";
          };
        }
      )}";
    };

  meta = {
    description = "Bilibili music desktop client";
    homepage = "https://github.com/wood3n/biu";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames sourceMap;
    mainProgram = "biu";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
