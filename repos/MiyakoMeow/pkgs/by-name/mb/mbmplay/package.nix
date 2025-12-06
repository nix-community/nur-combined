{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  p7zip,
  wineWowPackages,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mbmplay";
  version = "3.24.0824.1";

  src = fetchurl {
    url = "https://mistyblue.info/php/dl.php?file=mbmplay_3240824_1_x64.zip";
    sha256 = "0xingp3xpkb0wdsn2iwphskgg179vi45a8cr7yl3dznp3vxklxmz";
  };

  dontUnpack = true;
  dontBuild = true;
  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    p7zip
  ];

  installPhase = ''
    install -dm755 $out/share/${pname}
    7z x -y -o"$out/share/${pname}" "$src"
    # 修正反斜杠为目录分隔符
    while IFS= read -r -d $'\0' p; do
      case "$p" in
        *\\*)
          target="''${p//\\//}"
          if [ "$p" != "$target" ]; then
            mkdir -p "$(dirname "$target")"
            mv -f "$p" "$target"
          fi
        ;;
      esac
    done < <(find "$out/share/${pname}" -depth -print0)

    chmod -R u+rwX,go+rX $out/share/${pname}

    install -dm755 $out/bin

    install -Dm555 /dev/stdin $out/bin/mbmplay <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail

    APP_ROOT="@out@/share/${pname}"
    APP_DIR="$APP_ROOT/mBMplay"
    BASE_DATA_DIR="$(printenv XDG_DATA_HOME)"
    [ -n "$BASE_DATA_DIR" ] || BASE_DATA_DIR="$HOME/.local/share"
    USER_DATA="$BASE_DATA_DIR/${pname}"

    mkdir -p "$USER_DATA"

    # Repair symlinks in user data pointing to old store paths
    for link in "$USER_DATA"/*; do
      [ -L "$link" ] || continue
      name="$(basename "$link")"
      target="$(readlink -f "$link" 2>/dev/null || true)"
      if [ -z "$target" ] || [ ! -e "$target" ]; then
        if [ -e "$APP_ROOT/$name" ]; then ln -sfT "$APP_ROOT/$name" "$link"; fi
        continue
      fi
      case "$target" in
        "$APP_ROOT"/*)
          :
          ;;
        /nix/store/*)
          if [ -e "$APP_ROOT/$name" ]; then ln -sfT "$APP_ROOT/$name" "$link"; fi
          ;;
        *)
          :
          ;;
      esac
    done

    # Symlink all top-level files and directories from app into user data
    while IFS= read -r -d $'\0' entry; do
      name="$(basename "$entry")"
      if [ ! -e "$USER_DATA/$name" ]; then
        if [ -d "$entry" ]; then
          ln -sfT "$entry" "$USER_DATA/$name"
        else
          ln -sf "$entry" "$USER_DATA/$name"
        fi
      fi
    done < <(find "$APP_ROOT" -mindepth 1 -maxdepth 1 -print0)

    RUNTIME_DIR=$(mktemp -d -t ${pname}.XXXXXX)

    cleanup() {
      # Sync new top-level directories back to user data
      find "$RUNTIME_DIR" -mindepth 1 -maxdepth 1 -type d ! -name wineprefix | while read -r d; do
        name="$(basename "$d")"
        if [ ! -e "$USER_DATA/$name" ]; then
          cp -r --no-preserve=all "$d" "$USER_DATA/$name"
        fi
      done
      # Sync top-level files back to user data, skip app-shipped files
      while IFS= read -r -d $'\0' f; do
        base="$(basename "$f")"
        if [ ! -f "$APP_DIR/$base" ]; then
          cp -f "$f" "$USER_DATA/" 2>/dev/null || true
        fi
      done < <(find "$RUNTIME_DIR" -mindepth 1 -maxdepth 1 -type f -print0)
      rm -rf "$RUNTIME_DIR"
    }
    trap cleanup EXIT

    # Prepare runtime with app files
    cp -r "$APP_DIR"/. "$RUNTIME_DIR"/
    chmod -R u+rwX "$RUNTIME_DIR"

    # Link user data into runtime (files and directories)
    while IFS= read -r -d $'\0' f; do
      base="$(basename "$f")"
      [ -d "$RUNTIME_DIR/$base" ] && rm -rf "$RUNTIME_DIR/$base"
      ln -sf "$f" "$RUNTIME_DIR/$base"
    done < <(find "$USER_DATA" -mindepth 1 -maxdepth 1 -type f -print0)
    while IFS= read -r -d $'\0' d; do
      name="$(basename "$d")"
      [ -e "$RUNTIME_DIR/$name" ] && rm -rf "$RUNTIME_DIR/$name"
      ln -sfT "$d" "$RUNTIME_DIR/$name"
    done < <(find "$USER_DATA" -mindepth 1 -maxdepth 1 -type d -print0)

    cd "$RUNTIME_DIR"
    export WINEDEBUG=-all
    export WINEARCH=win64
    export WINEPREFIX="$RUNTIME_DIR/wineprefix"

    # 提供快速烟雾测试：仅验证脚本与目录准备是否正常
    if [ "$(printenv MBMPLAY_SMOKE)" = "1" ]; then
      echo "mbmplay smoke-ok"
      exit 0
    fi

    # 先禁用内置 mscoree/mshtml 以便安装 wine-mono
    export WINEDLLOVERRIDES="mscoree,mshtml=d"

    # 初始化前缀并安装 wine-mono（每次启动确保存在）
    MONO_DIR="${wineWowPackages.full}/share/wine/mono"
    MONO_MSI=$(ls "$MONO_DIR"/wine-mono-*.msi 2>/dev/null | head -n1 || true)
    if [ -n "$MONO_MSI" ]; then
      "${wineWowPackages.full}/bin/wine" msiexec /i "$MONO_MSI" /qn || true
    fi

    # 允许 mshtml，避免影响程序内嵌浏览器行为
    export WINEDLLOVERRIDES="mshtml="

    exec "${wineWowPackages.full}/bin/wine" "mBMplay.exe" "$@"
    EOF
    substituteInPlace $out/bin/mbmplay --replace "@out@" "$out"

    # 安装桌面文件
    copyDesktopItems
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "mBMplay";
      exec = pname;
      comment = "mBMplay - BMS 播放器 (Wine)";
      categories = [
        "Game"
        "AudioVideo"
        "Audio"
      ];
      terminal = false;
      keywords = [
        "BMS"
        "mBMplay"
        "Player"
      ];
      startupWMClass = "mBMplay";
      icon = "wine";
    })
  ];

  propagatedBuildInputs = [ wineWowPackages.full ];

  meta = with lib; {
    description = "mBMplay - BMS 播放器 (通过 Wine 运行)";
    homepage = "https://mistyblue.info";
    license = licenses.mit;
    maintainers = [ ];
    platforms = with lib.platforms; x86_64;
    mainProgram = pname;
  };
}
