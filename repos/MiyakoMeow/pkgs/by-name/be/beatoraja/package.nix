{
  stdenv,
  lib,
  pkgs,
  fetchurl,
  fetchzip,
  callPackage,
  makeDesktopItem,
  copyDesktopItems,
  unzip,

  # 默认参数
  javaPackageWithJavaFX ? pkgs.jdk23.override {
    enableJavaFX = true;
  },
  # 可选：传入 derivation 来覆盖 pname、version、meta，并从中获取 jar 文件
  # 如果提供，将使用该 derivation 的 pname、version、meta，并复制其 jar 文件到输出目录
  overrideDerivation ? null,
}:
let
  # 根据 jportaudio 设置类路径和库路径
  jportaudio = pkgs.jportaudio;
  jportaudioClassPath = ":${jportaudio}/share/java/*";
  jportaudioLibPath = "-Djava.library.path=${jportaudio}/lib";
in
stdenv.mkDerivation (finalAttrs: {
  pname = if overrideDerivation != null then overrideDerivation.pname else "beatoraja";

  beatorajaVersion = "0.8.8";
  version =
    if overrideDerivation != null then overrideDerivation.version else finalAttrs.beatorajaVersion;

  src = fetchurl {
    url = "https://www.mocha-repository.info/download/beatoraja${finalAttrs.beatorajaVersion}-modernchic.zip";
    sha256 = "sha256-yJwokOldNCUdvPtXqy1OL2ESGp446/aZBQevetGlp7Q=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    copyDesktopItems
  ];
  buildInputs = [
    javaPackageWithJavaFX
    pkgs.gtk3
    pkgs.gnome-themes-extra
    pkgs.colord-gtk
    pkgs.xorg.xrandr
    pkgs.xorg.libXrandr
    pkgs.ffmpeg
    jportaudio
  ];

  JAVA_HOME = javaPackageWithJavaFX.home;

  unpackPhase = ''
    runHook preUnpack

    # 解压原始 beatoraja zip
    unzip -qq -o $src
    mv beatoraja${finalAttrs.beatorajaVersion}-modernchic/* .
    rmdir beatoraja${finalAttrs.beatorajaVersion}-modernchic

    # 如果提供了 overrideDerivation，复制其 jar 文件
    ${
      if overrideDerivation != null then
        ''
          # 查找 overrideDerivation 输出中的 jar 文件并复制
          find ${overrideDerivation} -name "*.jar" -type f | while read jar; do
            cp "$jar" .
          done
        ''
      else
        ""
    }

    # 验证解压结果
    if [ ! -f ${finalAttrs.pname}.jar ]; then
      echo "ERROR: ${finalAttrs.pname}.jar not found after unpacking!"
      find . -type f
      exit 1
    fi

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # 创建标准目录结构
    mkdir -p $out/{bin,${finalAttrs.pname}-ori,share/beatoraja}

    # 安全复制文件
    find . -maxdepth 1 -type f -print0 | xargs -0 -I{} cp -- {} $out/${finalAttrs.pname}-ori/
    rm $out/${finalAttrs.pname}-ori/*.bat
    rm $out/${finalAttrs.pname}-ori/*.command
    rm $out/${finalAttrs.pname}-ori/*.dll
    find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I{} cp -r -- {} $out/share/${finalAttrs.pname}/

    # 创建启动脚本
    cat > $out/bin/${finalAttrs.pname} <<EOF
    #!${stdenv.shell}
    export JAVA_HOME="${javaPackageWithJavaFX.home}"
    export _JAVA_OPTIONS='-Dsun.java2d.opengl=true -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

    # 用户数据目录配置
    USER_DATA_DIR="\$HOME/.local/share/${finalAttrs.pname}"
    mkdir -p "\$USER_DATA_DIR"

    # 初始化用户目录结构
    for dir in $out/share/${finalAttrs.pname}/*/; do
      dir_name=\$(basename "\$dir")
      target_dir="\$USER_DATA_DIR/\$dir_name"

      if [ ! -d "\$target_dir" ]; then
        echo "Initializing directory: \$dir_name"
        cp -r --no-preserve=all "\$dir" "\$target_dir"
      fi
    done

    # 创建临时运行环境
    RUNTIME_DIR=\$(mktemp -d -t ${finalAttrs.pname}.XXX)

    # 文件同步逻辑
    config_files=(
      "beatoraja_log.xml"
      "config_sys.json"
      "songdata.db"
      "songinfo.db"
    )

    # 启动时：用户目录 -> 临时目录
    for cfg in "\''${config_files[@]}"; do
      user_cfg="\$USER_DATA_DIR/\$cfg"
      if [ -f "\$user_cfg" ]; then
        ln -sf "\$user_cfg" "\$RUNTIME_DIR/"
      fi
    done

    # 退出时：临时目录 -> 用户目录
    cleanup() {
      echo "Syncing config files back to user directory..."

      # 1. 同步配置文件
      for cfg in "\''${config_files[@]}"; do
        runtime_cfg="\$RUNTIME_DIR/\$cfg"
        if [ -f "\$runtime_cfg" ]; then
          cp -f "\$runtime_cfg" "\$USER_DATA_DIR/"
        fi
      done

      # 2. 同步新目录
      find "\$RUNTIME_DIR" -mindepth 1 -maxdepth 1 -type d | while read dir; do
        dir_name=\$(basename "\$dir")
        user_dir="\$USER_DATA_DIR/\$dir_name"

        # 如果用户目录不存在该目录，则复制
        if [ ! -d "\$user_dir" ]; then
          echo "Copying new directory: \$dir_name to user data"
          cp -r --no-preserve=all "\$dir" "\$user_dir"
        fi
      done
      rm -rf "\$RUNTIME_DIR"
    }
    trap cleanup EXIT

    # 链接必要文件
    ln -sf $out/${finalAttrs.pname}-ori/${finalAttrs.pname}.jar "\$RUNTIME_DIR/"

    # 创建符号链接到用户目录
    for dir in "\$USER_DATA_DIR"/*/; do
      dir_name=\$(basename "\$dir")
      ln -sfT "\$dir" "\$RUNTIME_DIR/\$dir_name"
    done

    # 运行游戏
    cd "\$RUNTIME_DIR"
    "${javaPackageWithJavaFX}/bin/java" -Xms1g -Xmx4g \\
    -XX:+UseShenandoahGC -XX:+ExplicitGCInvokesConcurrent -XX:+TieredCompilation -XX:+UseNUMA -XX:+AlwaysPreTouch \\
    -XX:-UsePerfData -XX:+UseThreadPriorities -XX:+ShowCodeDetailsInExceptionMessages \\
    ${jportaudioLibPath} \\
    -cp ${finalAttrs.pname}.jar${jportaudioClassPath}:ir/* \\
    bms.player.beatoraja.MainLoader "\$@"
    EOF

    # 设置脚本执行权限
    chmod +x $out/bin/${finalAttrs.pname}

    # 安装桌面文件
    copyDesktopItems

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = finalAttrs.pname;
      exec = finalAttrs.pname;
      comment = finalAttrs.meta.description;
      mimeTypes = [ "application/java" ];
      categories = [ "Game" ];
      terminal = false;
    })
  ];

  meta =
    if overrideDerivation != null then
      overrideDerivation.meta
    else
      (with lib; {
        description = "A modern BMS Player";
        homepage = "https://www.mocha-repository.info/download.php";
        license = licenses.gpl3;
        mainProgram = finalAttrs.pname;
      });
})
