{ lib
, stdenv
, autoPatchelfHook
, makeBinaryWrapper
, sources
}:
let
  os = if stdenv.hostPlatform.isDarwin then
    "darwin"
  else if stdenv.hostPlatform.isLinux then
    "linux"
  else
    throw "Unsupported OS: ${stdenv.hostPlatform.system}";

  arch = if stdenv.hostPlatform.isAarch64 then
    "arm64"
  else if stdenv.hostPlatform.isx86_64 then
    "amd64"
  else
    throw "Unsupported architecture: ${stdenv.hostPlatform.system}";

  pi-agent-bin = sources."pi-agent-bin-${arch}-${os}";
in stdenv.mkDerivation rec {
  pname = "pi-agent-bin";
  version = lib.removePrefix "v" pi-agent-bin.version;

  src = pi-agent-bin.src;

  nativeBuildInputs = [
    makeBinaryWrapper
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  # tarball 顶层是 pi/ 目录，二进制依赖同目录的 theme/、photon_rs_bg.wasm 等资源，
  # 整体安装到 lib/pi 后包一层 wrapper。
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/pi
    cp -r . $out/lib/pi
    chmod +x $out/lib/pi/pi

    mkdir -p $out/bin
    makeWrapper $out/lib/pi/pi $out/bin/pi

    runHook postInstall
  '';

  meta = with lib; {
    description = "pi coding agent (binary release)";
    homepage = "https://github.com/earendil-works/pi";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "pi";
  };
}
