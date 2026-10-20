{
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  python3,
  fcitx5,
  sources,
}:
let
  inherit (sources.qingjian) version src;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "qingjian";
  inherit version src;

  # 上游官方 Linux 预编译包（Rust 后端 + fcitx5 插件）。布局复用上游
  # install.sh 落盘：产品词库按 data.lock 校验后释放、插件 conf 的
  # Library 改写为 $out 内绝对路径；动态库路径由 autoPatchelfHook 补齐。
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    python3
    fcitx5
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    fcitx5
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    export XDG_DATA_HOME=$out/share
    bash install.sh --prefix $out

    wrapProgram $out/bin/qingjian-linux-server \
      --set QINGJIAN_RESOURCES $out/share/qingjian/resources

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/qingjian-team/qingjian/releases/tag/v${finalAttrs.version}";
    description = "Pinyin input method with translation hints for language learners";
    homepage = "https://qingjian.app";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "qingjian-linux-server";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
