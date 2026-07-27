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
  pi-agent-source = sources.pi-agent;
in
buildNpmPackage rec {
  pname = "pi-agent";
  version = pi-agent-source.version;

  # 与 kimi-code 同模式：tarball 的 package.json 不适合直接 install，
  # 构造一个仅依赖 @earendil-works/pi-coding-agent 的 wrapper 项目。
  src = stdenvNoCC.mkDerivation {
    name = "pi-agent-${version}-install-root";
    src = pi-agent-source.src;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cat > $out/package.json <<EOF
      {
        "name": "@earendil-works/pi-coding-agent-install",
        "version": "${version}",
        "private": true,
        "description": "Lockfile root used by the Pi installer and updater.",
        "dependencies": {
          "@earendil-works/pi-coding-agent": "${version}"
        },
        "overrides": {
          "protobufjs": "7.6.5",
          "rimraf": "6.1.2",
          "gaxios": {
            "rimraf": "6.1.2"
          }
        }
      }
      EOF
      cp ${./package-lock.json} $out/package-lock.json
      runHook postInstall
    '';
  };

  npmDepsHash = "sha256-5URorSJ1AFlwMZSDvnJc7dv6vhg6jooXp5mBYfSXI7M=";

  nativeBuildInputs = [
    makeBinaryWrapper
    python3
  ];

  buildInputs = [
    nodejs
  ];

  # npm 包已经带构建好的 dist/cli.js，不需要再跑 build 脚本
  dontNpmBuild = true;

  npmFlags = [ "--omit=dev" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r node_modules $out/lib/node_modules

    makeWrapper ${lib.getExe nodejs} $out/bin/pi \
      --add-flags "$out/lib/node_modules/@earendil-works/pi-coding-agent/dist/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "pi coding agent";
    homepage = "https://github.com/earendil-works/pi";
    license = lib.licenses.mit;
    mainProgram = "pi";
    platforms = lib.platforms.unix;
  };
}
