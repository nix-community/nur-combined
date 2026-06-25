{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

# 企业微信 / WeCom macOS (Apple Silicon) 官方 .app，直接从官网 dmg 解包。
# 版本/hash 由 lee 手动维护：
#   1. 打开 https://work.weixin.qq.com/#indexDownload
#   2. mac arm64 入口是 commdownload?platform=mac_arm64，它 302 到
#      https://dldir1.qq.com/foxmail/wecom-mac/updatebzl/WeCom_<ver>_Apple.dmg
#      （URL 干净、版本在文件名里，无轮换 hash —— 直接 curl -IL 跟重定向即可拿到）
#   3. `nix store prefetch-file <url>` 取 sha256
# 仅出 aarch64-darwin（Intel mac 用不到，不打包）。
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wxwork";
  version = "5.0.9.99905";

  src = fetchurl {
    url = "https://dldir1.qq.com/foxmail/wecom-mac/updatebzl/WeCom_${finalAttrs.version}_Apple.dmg";
    hash = "sha256-aUIAKH6uD63266tfwLm2mHXVpXOVEjooULBlv8Fj2A8=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ undmg ];

  # dmg 里的 bundle 是中文名「企业微信.app」。在 C-locale 的构建环境里直接拷会
  # 触发 mkdir 的 EILSEQ（Illegal byte sequence）。这里拷到 ASCII 目标名 WeCom.app
  # 绕开（macOS 仍按 Info.plist 的 CFBundleDisplayName 显示为「企业微信」），
  # 并设 UTF-8 locale 兜底。
  installPhase = ''
    runHook preInstall
    export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    app=$(find . -maxdepth 2 -name '*.app' -type d | head -1)
    if [ -z "$app" ]; then
      echo "WeCom .app not found after undmg" >&2
      exit 1
    fi
    mkdir -p "$out/Applications"
    cp -R "$app" "$out/Applications/WeCom.app"
    runHook postInstall
  '';

  meta = {
    description = "Tencent WeCom / 企业微信 (macOS Apple Silicon, official .app)";
    homepage = "https://work.weixin.qq.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
  };
})
