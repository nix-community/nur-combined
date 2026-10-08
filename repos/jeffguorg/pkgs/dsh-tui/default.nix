{
  lib
, stdenvNoCC
, buildNpmPackage
, makeBinaryWrapper
, jq
, nodejs
, sources
}:

let
  dsh-tui-source = sources.dsh-tui;
in
buildNpmPackage rec {
  pname = "dsh-tui";
  version = dsh-tui-source.version;

  # buildNpmPackage 需要把 src 当作 npm 项目根目录。
  # 上游 tarball 以 bundledDependencies 捆绑了未发布的 workspace 包（@dsh-std/*），
  # 其 package.json 带 workspace:* 协议依赖，npm 11 无法解析（无论 lockfile 里是否
  # 记录这些条目）。因此 install-root 不声明对 @deepseek-harness-tui/dsh-tui 的
  # 依赖，只声明它在 registry 发布的生产依赖，让 npm 解析一棵纯 registry 树；
  # 包本体（含捆绑的 node_modules）在 installPhase 直接从 nvfetcher 源码铺入，
  # 运行时由 node 的目录向上解析同时命中包内捆绑依赖与根级依赖。
  src = stdenvNoCC.mkDerivation {
    name = "dsh-tui-${version}-install-root";
    src = dsh-tui-source.src;
    nativeBuildInputs = [ jq ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      jq -n --slurpfile m $NIX_BUILD_TOP/package/package.json \
        '{name: "dsh-tui-install-root", version: "1.0.0", dependencies: $m[0].dependencies}' \
        > $out/package.json
      cp ${./package-lock.json} $out/package-lock.json
      runHook postInstall
    '';
  };

  npmDepsHash = "sha256-6asxBK8LB9EM4z/joDTyM21yVYdV/oZAr2rXhd4Fy3s=";

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildInputs = [
    nodejs
  ];

  # tarball 里已经包含构建好的 lib/，不需要再跑 build 脚本
  dontNpmBuild = true;

  # 上游 tarball 的依赖（dsh-working-activity）声明了 @deepseek-ai/* 非 optional peer，
  # 这些 peer 由 dsh harness 在运行时提供（bin 是委托启动器），不打进 lockfile；
  # 按 npm6 语义跳过 peer 解析，避免 npm ci 判定 lockfile 失同步后联网重解析
  npmFlags = [ "--omit=dev" "--legacy-peer-deps" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/dsh-tui/node_modules/@deepseek-harness-tui/dsh-tui
    cp -r node_modules $out/lib/dsh-tui/node_modules/
    tar -xzf ${dsh-tui-source.src} \
      -C $out/lib/dsh-tui/node_modules/@deepseek-harness-tui/dsh-tui \
      --strip-components=1

    # package.json 声明了 dsh-tui 与 dst 两个 bin，指向同一个入口
    for bin in dsh-tui dst; do
      # 同 pkgs/dsh：nix 编译的 node 上 node-addon-require-builtin 探测失败，
      # 带 --expose-internals 走普通 require 获取 internal 模块
      makeWrapper ${lib.getExe nodejs} $out/bin/$bin \
        --add-flags "--expose-internals" \
        --add-flags "$out/lib/dsh-tui/node_modules/@deepseek-harness-tui/dsh-tui/bin/dsh-tui.js"
    done

    runHook postInstall
  '';

  meta = {
    description = "Claude Code style interactive TUI front door for DeepSeek Harness agents";
    homepage = "https://github.com/ccch1mneyyy/dsh-TUI";
    license = lib.licenses.mit;
    mainProgram = "dsh-tui";
    platforms = lib.platforms.unix;
  };
}
