{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

# 腾讯会议 macOS (Apple Silicon) 官方 .app，直接从官网 dmg 解包。
# 版本/URL/hash 由 lee 手动维护：
#   1. 打开 https://meeting.tencent.com/download-mac.html（需能跑 JS 的浏览器）
#   2. 抓它请求的 query-download-info 接口，把 arch 换成 arm64，拿 updatecdn 直链
#   3. `nix store prefetch-file <url>` 取 sha256
# 仅出 aarch64-darwin（Intel mac 用不到，不打包）。
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wemeet";
  version = "3.43.10.444";

  src = fetchurl {
    url = "https://updatecdn.meeting.qq.com/cos/679380ae83cc15c5673e4d42acfcddcf/TencentMeeting_0300000000_${finalAttrs.version}.publish.arm64.officialwebsite.dmg";
    hash = "sha256-p7CjlFKsdz5hFLGum8mvtoCPMJDcl6YtdgU9pagiGq8=";
  };

  # undmg 的 setup-hook 会把 .dmg 解到当前目录；内容在卷名目录里。
  sourceRoot = ".";
  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall
    app=$(find . -maxdepth 3 -name 'TencentMeeting.app' -type d | head -1)
    if [ -z "$app" ]; then
      echo "TencentMeeting.app not found after undmg" >&2
      exit 1
    fi
    mkdir -p "$out/Applications"
    cp -r "$app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Tencent Video Conferencing / 腾讯会议 (macOS Apple Silicon, official .app)";
    homepage = "https://wemeet.qq.com";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
  };
})
