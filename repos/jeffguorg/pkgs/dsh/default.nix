{
  lib
, stdenvNoCC
, buildNpmPackage
, makeBinaryWrapper
, nodejs
, python3
, sources
}:

let
  dsh-source = sources.dsh;
in
buildNpmPackage rec {
  pname = "dsh";
  version = dsh-source.version;

  # buildNpmPackage 需要把 src 当作 npm 项目根目录。
  # registry tarball 只含构建产物（lib/bin.js），依赖全部声明在 package.json 里，
  # 因此构造一个仅依赖 @deepseek-ai/dsh 的 wrapper 项目，让 npm 解析完整生产
  # 依赖树（node-pty / koffi 在沙箱内以 node-gyp 构建，需 python3）。
  src = stdenvNoCC.mkDerivation {
    name = "dsh-${version}-install-root";
    src = dsh-source.src;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cat > $out/package.json <<EOF
      {
        "name": "dsh-install-root",
        "version": "1.0.0",
        "dependencies": {
          "@deepseek-ai/dsh": "${version}"
        }
      }
      EOF
      cp ${./package-lock.json} $out/package-lock.json
      runHook postInstall
    '';
  };

  npmDepsHash = "sha256-UKYKWsK4ZpzeRIziA+CNKqOzbrIHfi8QABi58oOU0ps=";

  nativeBuildInputs = [
    makeBinaryWrapper
    python3
  ];

  buildInputs = [
    nodejs
  ];

  # tarball 里已经包含构建好的 lib/bin.js，不需要再跑 build 脚本
  dontNpmBuild = true;

  # 上游把一批 cordis 插件（如 @deepseek-ai/cordis-plugin-group）声明为
  # 非 optional peer 并在运行时 import，依赖 npm 默认的 peer 自动安装把它们
  # 铺进依赖树；不能用 --legacy-peer-deps，否则运行时缺包
  npmFlags = [ "--omit=dev" ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/dsh
    cp -r node_modules $out/lib/dsh/node_modules

    makeWrapper ${lib.getExe nodejs} $out/bin/dsh \
      --add-flags "$out/lib/dsh/node_modules/@deepseek-ai/dsh/lib/bin.js"

    runHook postInstall
  '';

  meta = {
    description = "DeepSeek Harness (dsh) CLI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    mainProgram = "dsh";
    platforms = lib.platforms.unix;
  };
}
