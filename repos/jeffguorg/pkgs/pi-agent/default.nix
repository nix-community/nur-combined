{
  lib
, stdenvNoCC
, buildNpmPackage
, makeBinaryWrapper
, jq
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

  # wrapper 的 manifest 与 lockfile 同源：package.json 直接取自官方 install
  # lockfile 的根节点，不手写依赖或 overrides，以上游发布内容为准。
  src = stdenvNoCC.mkDerivation {
    name = "pi-agent-${version}-install-root";
    src = pi-agent-source.src;
    dontBuild = true;
    nativeBuildInputs = [ jq ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      jq '.packages[""]' ${./package-lock.json} > $out/package.json
      cp ${./package-lock.json} $out/package-lock.json
      runHook postInstall
    '';
  };

  npmDepsHash = "sha256-S/YWv1xPezJO3GhQIoQR3H0duPXT58CaGGAEu9aSJB4=";

  nativeBuildInputs = [
    jq
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

    mkdir -p $out/bin $out/lib/pi-agent
    cp -r node_modules $out/lib/pi-agent/node_modules

    makeWrapper ${lib.getExe nodejs} $out/bin/pi \
      --add-flags "$out/lib/pi-agent/node_modules/@earendil-works/pi-coding-agent/dist/cli.js"
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
