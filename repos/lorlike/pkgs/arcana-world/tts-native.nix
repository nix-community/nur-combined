{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, runCommand
, unzip
, cmake
, ninja
, python3
, pkg-config
}:

# 构建 Arcana 定制的 sherpa-onnx C ABI（含 WebGPU 扩展）以及配套的 ONNX Runtime
# 运行库。清单来源与上游 src 内 scripts/tts-native/sources.json 完全一致，这里
# 复刻一份是为了让 Nix 能离线取到 URL 与哈希——从 src 里 readFile 会触发 IFD，
# 而 CI 的 `nix-env -qa --drv-path` 在干净 store 上无法实例化派生。
let
  sources = import ./sources.nix { inherit fetchFromGitHub; };
  inherit (sources) src;

  manifest = builtins.fromJSON (builtins.readFile ./tts-sources.json);

  fetch = spec: fetchurl { inherit (spec) url sha256; };

  unpack = name: spec:
    runCommand "arcana-world-tts-source-${name}" {
      nativeBuildInputs = [ unzip ];
    } ''
      mkdir unpack
      cd unpack
      ${if lib.hasSuffix ".zip" spec.url
        then "unzip -q ${fetch spec}"
        else "tar -xf ${fetch spec}"}
      roots=(*)
      test "''${#roots[@]}" -eq 1
      cp -R "''${roots[0]}" "$out"
    '';

  goarch = if stdenv.hostPlatform.isAarch64 then "arm64" else "amd64";
  ortName = "onnxruntime-linux-" + (if stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64");

  # sherpa 的 FetchContent 只认本平台的那份 ONNX Runtime 预编译包。
  dependencies = lib.filterAttrs
    (name: _: !(lib.hasPrefix "onnxruntime-" name) || name == ortName)
    manifest.dependencies;
in
stdenv.mkDerivation {
  pname = "arcana-world-tts-native";
  inherit (sources) version;

  dontUnpack = true;
  dontStrip = true;
  # 构建由脚本自己驱动 CMake，不能让 stdenv 的 cmakeHook 先生成一轮。
  dontConfigure = true;
  dontUseCmakeConfigure = true;

  nativeBuildInputs = [ cmake ninja python3 unzip pkg-config ];

  # espeak-ng 以 -Wno-format 编译，与 Nix 默认的 -Werror=format-security 冲突。
  hardeningDisable = [ "format" ];

  buildPhase = ''
    runHook preBuild

    # 清单是上游脚本的输入，两者一旦漂移就说明 src 里换了版本，必须重新生成。
    diff -u ${src}/scripts/tts-native/sources.json ${./tts-sources.json}

    export TTS_SHERPA_SOURCE=${unpack "sherpa" manifest.sherpa}

    mkdir -p "$TMPDIR/tts-deps"
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList
      (name: spec: ''cp -R ${unpack name spec} "$TMPDIR/tts-deps/${spec.cmake_name}"'')
      dependencies)}
    chmod -R u+w "$TMPDIR/tts-deps"

    # 离线构建：脚本不再下载，全部走上面解包好的源码。
    export TTS_NATIVE_DEPS_DIR="$TMPDIR/tts-deps"
    export TTS_WEBGPU_PACKAGE=${fetch manifest.webgpu}
    export BUILD_JOBS="''${NIX_BUILD_CORES:-2}"

    python3 ${src}/scripts/build-tts-native.py \
      "$TMPDIR/native" "$TMPDIR/stage" linux ${goarch}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R "$TMPDIR/stage/." "$out/"
    chmod -R u+w "$out"

    # 上游用 $ORIGIN 部署运行库；构建目录的 RPATH 必须去掉，否则 fixup 会报
    # "forbidden reference to /build/"。
    for library in "$out"/*.so; do
      patchelf --set-rpath '$ORIGIN' "$library"
    done

    runHook postInstall
  '';

  meta = {
    description = "Pinned sherpa-onnx C ABI with Arcana's WebGPU extension";
    homepage = "https://github.com/TarocchiLive/arcana-world";
    license = lib.licenses.gpl3Only;
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
