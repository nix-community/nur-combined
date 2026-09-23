{
  lib,
  pkgs,
  sources,
}:

# pi-agent-git + anthropic server tools 补丁：
# Anthropic Messages 流里的 server_tool_use / web_search_tool_result / citations
# 在上游 pi 中无内部表示、回放时被丢弃（earendil-works/pi#709/#1740，维护者
# 明确不打算支持）。补丁在 pi-ai 流解析时逐字捕获原始 wire 块并旁挂在
# AssistantMessage.anthropicWireContent 上，同一 provider 回放时原样重发。
# 升级 pi 版本时若上游改动 anthropic-messages.ts，本补丁会 apply 失败，
# 构建随之失败（不会静默漂移）；需基于新源码重新生成。
let
  callPackage = lib.callPackageWith (pkgs // { inherit sources; });
  pi-agent-git = callPackage ../pi-agent/git.nix { };
in
pi-agent-git.overrideAttrs (prev: {
  pname = "pi-agent-patched";
  patches = (prev.patches or [ ]) ++ [ ./anthropic-server-tools-replay.patch ];
})
