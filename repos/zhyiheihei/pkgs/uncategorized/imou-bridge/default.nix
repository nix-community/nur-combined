{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  fetchurl,
}:
let
  # go2rtc 用于把每个摄像头的 DHP2P 隧道/RTSP 源转成多路 RTSP/WebRTC/HLS，
  # 与上游 Dockerfile 一致（v1.9.14）。
  go2rtc = fetchurl {
    url = "https://github.com/AlexxIT/go2rtc/releases/download/v1.9.14/go2rtc_linux_${
        if stdenv.hostPlatform.isAarch64 then "arm64" else "amd64"
      }";
    sha256 =
      if stdenv.hostPlatform.isAarch64 then
        "sha256-NZ+rreinpR6BpV/m32sO+BdkpeHWMXlXdTTqqnGQS1A="
      else
        "sha256-MtYWryJr1zFnj/3jKLlM+5TjAzm/78Rpz7djIxRGFaY=";
  };

  # 桥接依赖仅 flask（其余为 stdlib 与仓库内模块）。
  pythonEnv = python3.withPackages (ps: [ ps.flask ]);
in
stdenv.mkDerivation rec {
  pname = "imou-bridge";
  version = "2026-08-16";

  src = fetchFromGitHub {
    owner = "home-assistant-tools";
    repo = "imou-life";
    rev = "2e5617002637671b478ff6df82f7d615c58f6a40";
    hash = "sha256-DRl83LE/c2+/TBUzvvNUYp/g0oO9xXByT8A34Ik+dDo=";
  };

  sourceRoot = "source/deploy/dockge/imou-bridge";

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/imou-p2p-bridge $out/bin
    cp *.py $out/opt/imou-p2p-bridge/
    cp -r geelab_assets $out/opt/imou-p2p-bridge/
    install -m755 ${go2rtc} $out/bin/go2rtc
    runHook postInstall
  '';

  # 供 NixOS 模块直接取用解释器（supervisor 用 pythonEnv 跑）。
  passthru.pythonEnv = pythonEnv;

  meta = {
    description = "Imou/Lechange P2P bridge for Home Assistant and Frigate (go2rtc RTSP restream)";
    homepage = "https://github.com/home-assistant-tools/imou-life";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
