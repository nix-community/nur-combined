{ lib, stdenv, fetchurl, autoPatchelfHook, versionCheckHook }:

stdenv.mkDerivation {
  pname = "wxc";
  version = "0.1.0";

  # npm 平台包包含上游 Rust CLI；直接安装，不需要 Node.js 启动器。
  src = fetchurl {
    url = "https://registry.npmjs.org/@mkdir700/wxc-linux-x64/-/wxc-linux-x64-0.1.0.tgz";
    hash = "sha256-2ubDFKuwsfKl5fSul6dl9rRMXI4i9O1hErE8duDrEsw=";
  };
  sourceRoot = "package";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 bin/wxc "$out/bin/wxc"
    install -Dm644 LICENSE "$out/share/licenses/wxc/LICENSE"
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/wxc";

  meta = {
    description = "微信输入法设备关联与剪贴板命令行客户端（上游预编译包）";
    homepage = "https://github.com/mkdir700/wx-ime-sdk";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "wxc";
    platforms = [ "x86_64-linux" ];
  };
}
