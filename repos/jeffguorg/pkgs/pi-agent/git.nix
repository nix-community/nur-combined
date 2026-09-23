{
  lib,
  buildNpmPackage,
  makeBinaryWrapper,
  nodejs_22,
  sources,
}:

let
  pi-agent-git-source = sources.pi-agent-git;
in
buildNpmPackage rec {
  pname = "pi-agent-git";
  version = pi-agent-git-source.version;

  # 与 pi-agent（npm 预编译 tarball）不同，本包从源码构建。源是上游 release
  # 附带的确定性源码包（scripts/create-source-archive.sh 生成）：相比 git 树
  # 多出被 gitignore 的 packages/ai/src/providers/data/ 模型数据快照，
  # build:offline 依赖它。归档顶层目录为 pi-<version>。
  src = pi-agent-git-source.src;
  sourceRoot = "pi-${version}";

  # monorepo 构建需要 devDependencies（tsgo、esbuild、shx），不能 --omit=dev。
  # npm ci 由 npmConfigHook 以 --ignore-scripts 执行，与上游 CI 一致；tui 原生
  # 模块使用仓库内 prebuilds（缺失时运行时回退纯 JS），无需编译器。
  # fetcher 固定 v1：v2 会在计算哈希时在线抓取 registry packument，内容随注册表
  # 状态漂移，无法稳定复现；v1 只依赖 lockfile 本身。
  npmDepsFetcherVersion = 1;
  npmDepsHash = "sha256-JBIYoP2vvRNz1HONNvDJ1U3c+nmCJ7/VgNthRTkrkIA=";

  # nixpkgs 的 npmConfigHook 在 ci 后会 npm rebuild，会触发 canvas 等原生包的
  # install script（沙箱内无网络无 cairo）。上游 CI 全程 --ignore-scripts，
  # 原生模块使用 prebuilds 或运行时回退，这里保持一致。
  npmRebuildFlags = [ "--ignore-scripts" ];

  # 不联网的构建脚本：模型数据已随源码包提供，check:model-data 仅做校验
  npmBuildScript = "build:offline";

  nodejs = nodejs_22; # 上游 engines >= 22.19，CI 固定 node 22

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    # npm prune 不支持 workspaces（静默 no-op），改用二次 ci：按 lockfile 离线重装
    # 纯生产依赖树（缓存来自预取的 npmDeps），构建期 devDeps 至此不再进入产物
    npm ci --omit=dev --ignore-scripts

    mkdir -p $out/lib $out/bin
    # -L 解引用 workspaces 的相对符号链接（node_modules/@earendil-works/* →
    # packages/*），得到与 npm 发布一致的实体目录布局
    cp -rL node_modules $out/lib/

    # 运行时只读 dist；各 workspace 的 src/test 不随 npm 包发布，裁掉以缩小 closure
    for pkg in $out/lib/node_modules/@earendil-works/*/; do
      rm -rf "''${pkg}src" "''${pkg}test"
    done
    pkgOut=$out/lib/node_modules/@earendil-works/pi-coding-agent

    makeWrapper ${lib.getExe nodejs_22} $out/bin/pi \
      --add-flags "$pkgOut/dist/bundle/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "pi coding agent (built from the upstream source archive)";
    homepage = "https://github.com/earendil-works/pi";
    license = lib.licenses.mit;
    mainProgram = "pi";
    platforms = lib.platforms.unix;
  };
}
