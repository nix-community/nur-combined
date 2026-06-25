# nur-packages

Jeff Guo 的个人 [NUR](https://github.com/nix-community/NUR) 仓库，主要收集自己日常 NixOS / Home Manager 配置中需要、但暂未直接使用 nixpkgs 的包。

![Build and populate cache](https://github.com/jeffguorg/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-jeffguorg-blue.svg)](https://jeffguorg.cachix.org)

## 用法

推荐通过官方 NUR flake 引入，这也是 `/etc/nixos` 中当前使用的方式：

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = inputs@{ nixpkgs, nur, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [
              nur.overlays.default
            ];
          };
        }
      ];
    };
  };
}
```

启用 `nur.overlays.default` 后，本仓库的包会出现在 `pkgs.nur.repos.jeffguorg` 下。例如：

```nix
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.nur.repos.jeffguorg.agent-run
    pkgs.nur.repos.jeffguorg.claude-code-bin
    pkgs.nur.repos.jeffguorg.codex-bin
    pkgs.nur.repos.jeffguorg.create-tauri-app
  ];

  systemd.packages = [
    pkgs.nur.repos.jeffguorg.vagrant-vmware-utility
  ];
}
```

如果想使用本仓库的 Cachix 缓存，可以在 Nix 配置中加入：

```nix
{
  nix.settings = {
    substituters = [
      "https://jeffguorg.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "jeffguorg.cachix.org-1:hR16e5/t0lGrjNwKk8gnWKzh/h9lt2R4aR6JBDNQaaE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
```

本地开发或临时构建时，也可以直接从仓库根目录构建导出的包：

```console
nix build .#codex-bin
nix build .#claude-code-bin
nix-build -A agent-run
```

## 仓库内容

当前 `default.nix` 导出的内容：

| 属性名 | 说明 |
| --- | --- |
| `agent-run` | 统一管理和启动常见 coding agent 的命令行工具。 |
| `cursor-cli-bin` | Cursor Agent CLI 官方二进制包，主程序为 `cursor-agent`。 |
| `claude-code-bin` | Claude Code 官方二进制包，主程序为 `claude`。 |
| `codex` | 从源码构建的 OpenAI Codex CLI。 |
| `codex-bin` | OpenAI Codex CLI 官方二进制包。 |
| `create-tauri-app` | `tauri-apps/create-tauri-app` 的 Rust 包。 |
| `dingtalk` | 钉钉 Linux 桌面端打包。 |
| `kwok` | Kubernetes SIGs 的 KWOK / `kwokctl` 工具。 |
| `vagrant-vmware-utility` | Vagrant VMware Utility，适配 NixOS 上的 VMware Workstation 路径和 systemd 服务。 |
| `caddy-with-plugins` | 通过 `pkgs.caddy.withPlugins` 构建的自定义 Caddy，附带 tencentcloud DNS、cache-handler、caddy-tailscale 插件。 |
| `lib` | NUR 保留属性，目前没有自定义函数。 |
| `modules` | NUR 保留属性，目前没有自定义 NixOS module。 |
| `overlays` | NUR 保留属性，目前没有额外 overlay。 |

源码版本由 `nvfetcher.toml` 管理，生成结果位于 `_sources/`。Go 包的 vendor hash 更新由 `scripts/update-go-vendorHash.sh` 处理。Caddy（`withPlugins`）的插件版本同步由 `scripts/update-caddy-plugins.sh` 处理，vendor hash 更新由 `scripts/update-caddy-hash.sh` 处理（前者会自动调用后者）。

## 自动更新与 CI

仓库有两个 GitHub Actions workflow：

- `Build and populate cache`：在 push、pull request、手动触发时运行，并按计划每天 `03:40 UTC` 构建、填充 `jeffguorg` Cachix 缓存，同时触发 NUR 更新。
- `Auto update packages`：支持手动触发，并按计划每天 `05:55 UTC` 运行 `scripts/auto-update.sh`、`nix flake update`，必要时更新 Go vendor hash，然后以 `auto: update packages` 自动提交回仓库。
