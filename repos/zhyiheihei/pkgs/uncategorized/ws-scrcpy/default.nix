{
  lib,
  buildNpmPackage,
  nodejs,
  python3,
  android-tools,
  sources,
}:
# ws-scrcpy：网页版 scrcpy（NetrisTV），浏览器经 adb 镜像/控制 Android 设备。
# 上游发版停滞但 master 活跃维护（nvfetcher 锁 master commit），Nix 生态无现成打包。
# 后端用 webpack-node-externals，运行时依赖留在 node_modules，因此安装 dist +
# node_modules 整树；scrcpy-server.jar 经 file-loader 打进 dist。
let
  inherit (sources.ws-scrcpy) src version;
in
buildNpmPackage (finalAttrs: {
  pname = "ws-scrcpy";
  inherit src version;

  # 裸听 0.0.0.0 会绕过 nginx 的 OAuth 入口，加 WS_SCRCPY_BIND_HOST 绑定地址支持
  patches = [ ./0001-bind-address-env.patch ];

  # 上游没声明 engines，社区镜像历史用 node 16；master 依赖已现代化
  # （webpack 5 / ws 8 / express 4.22），nixpkgs 已无 16/18，用当前 LTS 实测
  nodejs = nodejs;

  # node-pty 是唯一原生依赖（node-gyp 编译，aarch64/x86_64 双端均本地编译）
  nativeBuildInputs = [ python3 ];

  npmDepsHash = "sha256-lm2evW0WoE1xF6cxV9tRwF3XK/PqwpTsznp/KethO2k=";

  # appium 是 iOS 专用 optionalDependency（数百 MB），Android 链路用不到；
  # postinstall(setup-appium.js) 检测到 appium 缺席会自动退出 0
  npmInstallFlags = [ "--omit=optional" ];

  # 上游构建脚本是 dist（webpack production：前端 bundle + 后端 node target）
  npmBuildScript = "dist";

  npmPruneFlags = [
    "--omit=dev"
    "--omit=optional"
  ];

  # 上游默认 installPhase 按 npm pack 取文件，会丢掉 node_modules；
  # 后端依赖是运行时 external（webpack-node-externals），必须整树安装
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ws-scrcpy $out/bin
    npm prune --omit=dev
    cp -r dist node_modules package.json $out/lib/ws-scrcpy/
    makeWrapper ${nodejs}/bin/node $out/bin/ws-scrcpy \
      --prefix PATH : ${
        lib.makeBinPath [
          android-tools
        ]
      } \
      --add-flags "$out/lib/ws-scrcpy/dist/index.js"
    runHook postInstall
  '';

  meta = {
    description = "Control Android devices from your browser via scrcpy over WebSocket";
    homepage = "https://github.com/NetrisTV/ws-scrcpy";
    changelog = "https://github.com/NetrisTV/ws-scrcpy/commits";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "ws-scrcpy";
  };
})
