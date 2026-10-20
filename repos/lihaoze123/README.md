# nur-packages

基于 [nix-community/nur-packages-template](https://github.com/nix-community/nur-packages-template)
创建，模板版本固定为 [`b885a769`](https://github.com/nix-community/nur-packages-template/tree/b885a769f27b0d6dfa815c4497c3694a7412904f)。

![Build and populate cache](https://github.com/lihaoze123/nur-packages/actions/workflows/build.yml/badge.svg)

lihaoze123 的独立 NUR 软件包仓库。软件包配方集中维护，安装由 `nix profile`
管理。标准软件直接使用 `nixpkgs`；此处维护自定义包及定制版本。

| 包 | 内容 |
| --- | --- |
| `cloudflare-cli` | Cloudflare 官方 `cf` / `cloudflare` CLI，使用 npm 发布包 |
| `dbx` | DBX 官方预编译 AppImage，包含 NixOS 启动环境、菜单入口和图标 |
| `fcitx5-vinput-lite`、`fcitx5-vinput-lite-upstream` | 云端语音输入插件；前者含按键重复修复及回归测试，后者保留原版 |
| `vtype-linux` | 微信拼音 Fcitx5 插件，含小鹤双拼、模糊音、自定义翻页键和固定运行时 |
| `wxc` | 微信输入法设备关联与剪贴板客户端，使用官方预编译包 |
| `honk` | 带原生 API 和内嵌 doona 的固定预编译版本 |
| `try` | tobi/try，修复 NixOS Ruby shebang |
| `vscode` | VS Code，包含原有六个扩展 |
| `dms-xhup` | DMS 小鹤音形插件 |
| `edunet` | 校园网 ePortal CLI |
| `oseasy-helper` | 噢易课堂广播视频与文件接收 CLI；官方学生端管理功能仅支持 Windows |
| `codex-desktop`、`codex-computer-use`、`codex-computer-use-niri`、`niri-patched` | niri 上的 Codex Computer Use，固定桌面、后端、niri 和补丁版本 |
| `gxfp5130-fprintd`、`gxfp5130-libfprint`、`gxfp5130-tools`、`gxfp5130-kernel` | GXFP5130 ChicagoHS 指纹支持 |

目前 Flake 输出支持 `x86_64-linux`。`vscode` 包含非自由软件；Flake 入口已允许，
通过传统 NUR 入口使用时由调用者设置 `config.allowUnfree`。

## 安装与更新

直接从 GitHub 安装：

```sh
nix profile install github:lihaoze123/nur-packages#dbx
nix profile install github:lihaoze123/nur-packages#vtype-linux
nix profile upgrade dbx
nix profile remove dbx
```

本地开发：

```sh
nix profile install .#dbx
nix fmt
nix flake check --no-build
nix build .#dbx
```

DBX 的构建仅解包官方二进制并生成 Nix 启动环境，不编译 DBX 源码。
VType 从源码构建插件和 Android 宿主程序；引擎、词库、设备身份另存于用户目录，
安装和更新 Nix 包不会自动初始化、关联设备或重启输入法。
VType 的初始化与运行说明见 [pkgs/vtype-linux/README.md](pkgs/vtype-linux/README.md)。

## 缓存

缓存地址和公钥集中维护在 `lib/cache-config.nix`，由主机 Nix 配置直接启用。
下载使用普通 `nix build`、`nix profile` 或系统构建命令，无需额外的安装器或缓存选择包装。
长期使用的软件应声明在 NixOS / Home Manager 配置中，`nix profile` 仅用于临时试用。

私有 NUR 缓存为 `https://cache.chumeng.xyz/nur`。在已配置只读凭据的 NixOS 主机上，
可直接声明：

```nix
nix.settings = {
  extra-substituters = [ "https://cache.chumeng.xyz/nur" ];
  extra-trusted-public-keys = [ "nur:dJh05Op2+iv3GCHoaF2+1FfQtqcUZzf/4v/ZTaLHomY=" ];
  netrc-file = "/run/agenix/attic-netrc";
};
```

`netrc-file` 应指向主机密钥管理工具生成的 root 可读文件；不要将明文 token 写进
Nix 配置或 Nix store。公开项目缓存也由主机按需声明，NUR 包自身不改写客户端配置。
签名私钥由 Attic 服务端管理，上传使用单独的 token。

CI 对三个渠道执行传统 NUR 求值检查；私有缓存目标由
`ciMetadata.x86_64-linux.buildJobPackages` 自动生成，包含全部可构建包和所有输出，
包括 Codex、VS Code 等非自由包。broken 和不支持当前平台的包不进入构建矩阵。
`ci.nix` 保留模板的公共筛选规则，私有缓存不受其非自由软件过滤限制。

`nix-eval-jobs` 分别求值每个目标，求值错误会记录并使最终检查失败，其他正常目标
仍可继续构建。只有全部输出都存在于私有 Attic 的包才跳过；上游 Cachix 命中
不能替代私有缓存命中。每个包独立构建全部输出，成功后立即上传运行时闭包，
再核对 StorePath、NarHash、NarSize 和 References。已有官方缓存签名的公共依赖
不重复上传；显式导出的目标输出始终保存到私有 Attic。

每日 03:17 UTC 检查缓存覆盖，每周一额外在空 store 中下载全部目标及运行时依赖，
验证签名和内容；不会在验证 store 中编译缺失产物。也可手动运行构建工作流并打开
`audit`。PR 只构建验证，只有 main/master 的非 PR 工作流可以上传。

传统 NUR 和 overlay 使用调用方提供的 `pkgs`，Flake 使用本仓库锁定的 nixpkgs。
私有缓存命中要求源码、nixpkgs 和包参数一致；包名、版本相同还不够。
通过主机 overlay 消费时，主机 nixpkgs 的更新可能改变产物路径。
本次将四个上游项目迁入标准入口后，原有 10 个标准包的路径不变，迁入的 9 个包
需要重新构建并上传；另新增可直接使用的 `gxfp5130-kernel` 包。

GitHub Secret `ATTIC_TOKEN` 只允许读取、上传 `nur` 缓存，无管理或删除权限。
`scripts/cache-attic.sh` 使用临时 token 文件上传闭包，结束后清理；公开缓存公钥
由 `lib/cache-config.nix` 维护。旧对象存储上传链路已移除。

## NUR、Flake 和 overlay

`default.nix` 符合传统 NUR 接口，维护本地配方及缓存工具，所有依赖取自调用者的 `pkgs`。
全部 20 个包由 `lib/package-set.nix` 自动发现，传统 NUR、Flake 和 overlay
共用同一份配方。源码版本与哈希固定在包目录的 JSON 文件中；构建时下载源码，
查询时只读取仓库内的配方、补丁、Cargo 锁文件和特性清单，不需要远程源码 IFD。
Codex Desktop 的 Linux 运行时配方保留上游许可证，来源及固定版本见
`pkgs/codex-desktop/LICENSE.upstream` 和 `sources.json`。

```nix
import ./default.nix { inherit pkgs; }
```

通过官方 NUR 输入使用：

```nix
inputs.nur.url = "github:nix-community/NUR";
inputs.nur.inputs.nixpkgs.follows = "nixpkgs";

# 在 NixOS 模块内，Home Manager 使用同一 pkgs 时也可直接引用
nixpkgs.overlays = [ inputs.nur.overlays.default ];
environment.systemPackages = [
  pkgs.nur.repos.lihaoze123.dbx
];

# 标准模块元数据不依赖 pkgs，可以直接导入
imports = [ inputs.nur.repos.lihaoze123.modules.nixos.edunet ];
```

Overlay 将软件包放在 `pkgs.nur-lihaoze123` 中，不覆盖 nixpkgs 同名包。

本仓库已通过 [NUR #1247](https://github.com/nix-community/NUR/pull/1247) 登记。
新包推送并通过官方求值、索引更新后，会出现在
[NUR 搜索页](https://nur.nix-community.org/repos/lihaoze123/)，无需逐包提交登记 PR。
客户端运行 `nix flake update nur` 获取新的官方索引。

## 模板结构

- `default.nix`、`lib/package-set.nix`：自动发现 `pkgs/<包名>/default.nix`，保留模板预留的入口。
- `flake.nix`：从标准包集生成按系统的输出，复用本地 NixOS 模块，并固定维护用的上游输入。
- `ci.nix`：模板提供的构建与缓存输出筛选。
- `ci-private.nix`：私有缓存的全包构建集合、全部输出及更新脚本。
- `lib/`、`nixos-modules/`、`overlays/` 和 `overlay.nix`：模板的扩展入口。
- `.github/workflows/build.yml`、`.github/dependabot.yml`：模板的 CI 与依赖维护配置。

适配项：当前包只支持 x86_64 Linux；Flake 允许 VS Code 的非自由许可证；
nixpkgs 沿用迁移前的锁定版本；overlay 使用独立命名空间，避免覆盖 nixpkgs 中的
`try`、`vscode` 等同名包。模板示例包已由实际软件包替代。

## 维护

更新包时修改版本、源码修订和哈希，再对该包求值、构建及检查。
`flake.lock` 固定 nixpkgs，保持运行依赖可复现；需要更新时执行 `nix flake update nixpkgs`。
新增本地包只需添加 `pkgs/<包名>/default.nix`，无需再修改包名清单；包注册、
CI 目标和默认更新脚本自动生成。四个项目的 Flake 输入仅供维护时固定、获取上游源码；
更新任务从 `flake.lock` 的根输入发现，更新后调用 `scripts/sync-project-inputs.py`
同步配方、模块、源码哈希、补丁及求值元数据。相关包通过 `update.json` 的 `group`
复用项目更新任务，包括包名与输入名相同的情况；不会重复生成独立包更新任务。
上游目录或配方结构发生变化时，同步脚本会报错，需人工检查适配后再合并更新 PR。

每周一 02:43 UTC 按独立包或配套组件组生成更新 PR，不自动合并。优先稳定发行版
及稳定标签，没有稳定版的源码项目跟踪分支；仅提供预编译文件的项目使用可用的发布渠道。
普通包默认运行 `nix-update`，特殊更新器或分组声明放在包目录的 `update.json`，
不维护中央包名清单。例如 vinput 原版随补丁版更新，VS Code 随 nixpkgs 更新，
Computer Use 的配套输入作为一个整体更新。
npm 包不会从较新的预发布版回退到旧稳定版；此时沿用 `latest` 渠道，稳定版追上后再切换。
固定 GitHub 提交的包使用 `kind = "github"` 更新器，同时更新版本号、源码提交和哈希，
避免只修改展示版本而仍然构建旧源码。
源码更新仅采用包含当前提交的后续版本；稳定标签落后时跟踪默认分支，分支回退时保留当前提交。

手动执行某个包的更新脚本（在仓库根目录）：

```sh
nix run .#ciMetadata.x86_64-linux.updateScripts.fcitx5-vinput-lite
python3 scripts/update-package.py --list
```

自动 PR 使用 `GITHUB_TOKEN`，需要在仓库 Actions 设置中允许创建 Pull Request。
更新 PR 创建后显式触发构建工作流，无需额外 PAT；PR CI 不上传，合并后进入私有缓存。
Dependabot 每周只更新 Actions 依赖，Nix 输入由上述分组更新工作流处理。
项目公开 Cachix 缓存用于相关构建的下载；进入 NUR 公共索引后，
将 `NUR_REGISTERED` 设为 `true`，成功的 push 工作流会通知 NUR 更新。
回归脚本在 `tests/vtype-linux/`，仅在相关代码发生变化时运行。

本仓库的软件包配方、文档与测试采用 MIT 许可证；VType 和 vinput 补丁沿用上游
GPL-3.0 许可证。打包的软件自身许可证见各包的 `meta.license`。
