{ lib
, buildGoModule
, fetchFromGitHub
, alsa-lib
, stdenv
, ttsNative
}:

# 统一 TTS 辅助程序：本地播放（oto → dlopen libasound）、sherpa-onnx 本地模型
# （WebGPU / CPU）以及边缘/云厂商语音。
#
# 运行库布局与上游 scripts/build.sh 产出的 libexec 一致——主程序只在该目录
# 里找 arcana-world-tts 及其 *.so，所以全部平铺在 $out/libexec。
buildGoModule rec {
  pname = "arcana-world-tts";

  inherit (import ./sources.nix { inherit fetchFromGitHub; }) version src;

  # 与 arcana-world 主程序同一 src、同一依赖图，故共用同一个 vendor 哈希。
  proxyVendor = true;
  vendorHash = "sha256-pczP2+cgD4jM1R+HnSOEL9PqIaquqJ8yU9LT3PIhtlI=";

  subPackages = [ "cmd/arcana-world-tts" ];
  env.CGO_ENABLED = "1";
  tags = [ "tts" ];

  # Go 侧不链接 Nix 里的 sherpa：cgo LDFLAGS 指向 Go module 自带的 lib/，
  # 真正生效的是运行时 $out/libexec 下随包发布的定制构建。
  buildInputs = [ alsa-lib stdenv.cc.cc.lib ];

  # 依赖下载阶段既不需要原生库，也不该继承 preBuild。
  overrideModAttrs = _: { preBuild = ""; };

  ldflags = [ "-s" "-w" ];

  checkPhase = ''
    runHook preCheck
    go test -tags tts ./internal/tts/... ./cmd/arcana-world-tts
    runHook postCheck
  '';

  # oto 用 purego dlopen("libasound.so.2")，ELF 依赖扫描看不到，必须显式补
  # RPATH；同时用 $ORIGIN 让 libexec 里的 sherpa/ORT 副本优先于任何构建期路径。
  # 两个 fixup hook 都会重写 RPATH，所以必须一起关掉，RPATH 完全由下面设置。
  dontAutoPatchelf = true;
  dontPatchELF = true;

  postInstall = ''
    mkdir -p "$out/libexec"
    mv "$out/bin/arcana-world-tts" "$out/libexec/arcana-world-tts"
    rmdir "$out/bin"

    install -Dm755 ${ttsNative}/libsherpa-onnx-c-api.so "$out/libexec/libsherpa-onnx-c-api.so"
    install -Dm755 ${ttsNative}/libonnxruntime.so "$out/libexec/libonnxruntime.so"
    install -Dm755 ${ttsNative}/libonnxruntime_providers_webgpu.so \
      "$out/libexec/libonnxruntime_providers_webgpu.so"

    mkdir -p "$out/share/licenses/tts"
    cp -R ${ttsNative}/licenses/tts/. "$out/share/licenses/tts/"

    rpath="\$ORIGIN:${lib.makeLibraryPath [ alsa-lib stdenv.cc.cc.lib ]}"
    for binary in "$out/libexec/arcana-world-tts" "$out/libexec/"*.so; do
      patchelf --set-rpath "$rpath" "$binary"
    done
  '';

  meta = {
    description = "Speech helper for arcana-world: playback, local MeloTTS/Kokoro/Piper voices and cloud TTS";
    homepage = "https://github.com/TarocchiLive/arcana-world";
    license = lib.licenses.gpl3Only;
    mainProgram = "arcana-world-tts";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [
      {
        name = "lorlike";
        github = "lorlike";
        githubId = 47685593;
      }
    ];
  };
}
