{
  lib
, stdenvNoCC
, buildNpmPackage
, fetchurl
, makeBinaryWrapper
, nodejs
, python3
, sources
}:

let
  kimi-code-source = sources.kimi-code;
in
buildNpmPackage rec {
  pname = "kimi-code";
  version = kimi-code-source.version;

  # buildNpmPackage 需要把 src 当作 npm 项目根目录。
  # tarball 本身的 package.json 带有未在 registry 发布的 devDependencies，
  # 无法直接 install；因此构造一个仅依赖 @moonshot-ai/kimi-code 的 wrapper 项目，
  # 让 npm 只安装产物运行所需的 optional/native 依赖。
  src = stdenvNoCC.mkDerivation {
    name = "kimi-code-${version}-install-root";
    src = kimi-code-source.src;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cat > $out/package.json <<EOF
      {
        "name": "kimi-code-install-root",
        "version": "1.0.0",
        "dependencies": {
          "@moonshot-ai/kimi-code": "${version}"
        }
      }
      EOF
      cp ${./package-lock.json} $out/package-lock.json
      runHook postInstall
    '';
  };

  npmDepsHash = "sha256-bFOTVmLbIsgF5hQlTxB+FXkU2vzzMgnhQQLcqqXxZz8=";

  nativeBuildInputs = [
    makeBinaryWrapper
    python3
  ];

  buildInputs = [
    nodejs
  ];

  # tarball 里已经包含构建好的 dist/main.mjs，不需要再跑 build 脚本
  dontNpmBuild = true;

  # 只安装生产依赖（koffi / node-pty / clipboard）
  npmFlags = [ "--omit=dev" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r node_modules $out/lib/node_modules

    makeWrapper ${lib.getExe nodejs} $out/bin/kimi \
      --add-flags "$out/lib/node_modules/@moonshot-ai/kimi-code/dist/main.mjs"

    runHook postInstall
  '';

  # postinstall.mjs 会在全局安装时尝试迁移旧版 Python CLI 的 PATH shim，
  # Nix 构建沙箱里不需要，且可能误操作；禁用它。
  postFixup = ''
    rm -f $out/lib/node_modules/@moonshot-ai/kimi-code/scripts/postinstall.mjs
  '';

  meta = {
    description = "The Starting Point for Next-Gen Agents";
    homepage = "https://github.com/MoonshotAI/kimi-code";
    license = lib.licenses.mit;
    mainProgram = "kimi";
    platforms = lib.platforms.unix;
  };
}
