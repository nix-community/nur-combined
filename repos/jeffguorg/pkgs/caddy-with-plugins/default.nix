{ pkgs }:

let
  plugins = [
    "github.com/caddy-dns/tencentcloud@v0.4.3"
    "github.com/caddyserver/cache-handler@v0.16.0"
    # caddy-tailscale 仓库无 git tag，这里钉到 main 分支 commit
    # bb080c4414acd465d8be93b4d8f907dbb2ab2544 的 Go pseudo-version。
    # 升级时用 `go get github.com/tailscale/caddy-tailscale@<新commit>` 重新解析出 pseudo-version。
    "github.com/tailscale/caddy-tailscale@v0.0.0-20260106222316-bb080c4414ac"
  ];
in
pkgs.caddy.withPlugins {
  inherit plugins;
  # vendor output hash；插件/版本变更后跑 scripts/update-caddy-hash.sh 更新。
  hash = "sha256-TmEQFzZDf9aH7k5slPcbMmy+toxEdyR4HPwymUxDh/E=";
}
