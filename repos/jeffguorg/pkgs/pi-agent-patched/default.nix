{
  lib,
  pkgs,
  sources,
}:

# pi-agent-git + anthropic server tools 补丁：
# Anthropic Messages 流里的 server_tool_use / web_search_tool_result / citations
# 在上游 pi 中无内部表示、回放时被丢弃（earendil-works/pi#709/#1740，维护者
# 明确不打算支持）。补丁做两件事：
# 1. 在 pi-ai 流解析时逐字捕获原始 wire 块并旁挂在
#    AssistantMessage.anthropicWireContent 上，同一 provider 回放时原样重发。
# 2. 为 server tool 块发新的流事件 server_tool_start / server_tool_end，并
#    把它们加入 agent loop 的 message_update 白名单，让扩展能在消息流式期间
#    感知内联搜索（否则面板只能等 message_end，排序落后于工具面板）。
# 3. 在启动时发布 globalThis.__PI_PATCH_CAPABILITIES__（版本 + 能力表，
#    packages/coding-agent/src/patch-capabilities.ts），供扩展探测补丁能力；
#    stock pi 无此全局，扩展据此回退到 stock 行为。
# 升级 pi 版本时若上游改动 anthropic-messages.ts / agent-loop.ts，本补丁会
# apply 失败，构建随之失败（不会静默漂移）；需基于新源码重新生成。补丁集
# 变更时同步 bump patch-capabilities.ts 里的 version。
let
  callPackage = lib.callPackageWith (pkgs // { inherit sources; });
  pi-agent-git = callPackage ../pi-agent/git.nix { };
in
pi-agent-git.overrideAttrs (prev: {
  pname = "pi-agent-patched";
  patches = (prev.patches or [ ]) ++ [ ./anthropic-server-tools-replay.patch ];
})
