{ fetchFromGitHub }:

# 三个派生（TUI、TTS 原生库、TTS helper）必须锁在同一份上游快照上：
# tts-native.nix 会用 src 里的 scripts/ 驱动构建，tts.nix 又依赖前者产物。
rec {
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "TarocchiLive";
    repo = "arcana-world";
    tag = "v${version}";
    hash = "sha256-hNfrr2mIH2reXM98qBHNWa5UGRRoFnaH0/Phe23y9ek=";
  };
}
