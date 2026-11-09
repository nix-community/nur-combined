{
  lib,
  pkgs,
  buildGoModule,
  fetchFromGitHub,
  runCommand,
  # 拉取 Go 依赖用的代理。默认走 goproxy.io 而不是官方 proxy.golang.org，
  # 因为国内网络直连官方代理会超时；goproxy.io 在境外同样可用。
  # 注意：该代理必须保留 .info 里的 Origin 字段，否则 go modules 缓存内容
  # 会变化，连带让 vendorHash 失效（goproxy.cn / 阿里云镜像会丢该字段）。
  goproxy ? "https://goproxy.io,direct",
  # 允许外部注入已构建好的原生部分（本地验证或自定义 nixpkgs）。
  ttsNative ? pkgs.callPackage ./tts-native.nix { },
  ttsHelper ? pkgs.callPackage ./tts.nix { inherit ttsNative; },
}:

# 两个变体：
#   arcana-world     —— TUI + libexec 下的 TTS 辅助程序（默认，开启语音）
#   passthru.tui     —— 只有 TUI，不链接任何原生库
#
# TTS 依赖 Linux 上的 ALSA 与预编译的 sherpa-onnx/ONNX Runtime，所以 Darwin
# 上只能退化成纯 TUI 变体。
let
  tui = buildGoModule rec {
    pname = "arcana-world";
    version = "0.4.4";

    inherit (import ./sources.nix { inherit fetchFromGitHub; }) src;

    # 与上游 flake.nix 中的同名派生保持一致：依赖走 Go module proxy 拉取后再算
    # vendor 哈希，所以这里的 vendorHash 可以直接沿用上游（其 CI 每次 push 都会
    # 构建 .#default 来校验它）。带 tts tag 的辅助程序共用同一份依赖图和哈希。
    proxyVendor = true;
    vendorHash = "sha256-pczP2+cgD4jM1R+HnSOEL9PqIaquqJ8yU9LT3PIhtlI=";

    # goModules 是 fixed-output 派生，而 buildGoModule 把 GOPROXY 列进了
    # impureEnvVars —— 构建时构建机的 GOPROXY（通常为空）会覆盖这里 env 的值，
    # go 就会回落到 proxy.golang.org。所以显式固定代理，并把它从
    # impureEnvVars 里摘掉，让产物只取决于 vendorHash。
    overrideModAttrs = _: prev: {
      impureEnvVars = builtins.filter (n: n != "GOPROXY") (prev.impureEnvVars or [ ]);
    };

    subPackages = [ "cmd/arcana-world" ];
    env = {
      CGO_ENABLED = "0";
      GOPROXY = goproxy;
    };
    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    checkPhase = ''
      runHook preCheck
      go test ./...
      runHook postCheck
    '';

    postInstall = ''
      install -Dm644 LICENSE "$out/share/licenses/arcana-world/LICENSE"
    '';

    meta = {
      description = "A lightweight TUI alternative to bilibili LiveHime";
      homepage = "https://github.com/TarocchiLive/arcana-world";
      license = lib.licenses.gpl3Only;
      mainProgram = "arcana-world";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      maintainers = [
        {
          name = "lorlike";
          github = "lorlike";
          githubId = 47685593;
        }
      ];
    };
  };

  # 辅助程序与主程序共用同一份 go.mod，直接复用它的模块缓存，避免 CI 把
  # 几百 MB 依赖再下载一遍（两者 pname 不同，默认会得到两个不同的派生）。
  helper = ttsHelper.overrideAttrs (_: { goModules = tui.goModules; });
in
if !pkgs.stdenv.hostPlatform.isLinux then
  tui
else
  # 主程序用 helperpath.Installed 在自身真实路径旁找 libexec/arcana-world-tts，
  # 并且会 EvalSymlinks，所以必须复制可执行文件而不是建立符号链接。
  runCommand "arcana-world-${tui.version}"
    {
      meta = tui.meta // {
        description = "A lightweight TUI alternative to bilibili LiveHime, with TTS support";
      };
      passthru = {
        inherit tui ttsNative helper;
      };
    }
    ''
      mkdir -p "$out/bin"
      install -m755 ${tui}/bin/arcana-world "$out/bin/arcana-world"
      cp -R ${helper}/libexec "$out/bin/libexec"

      mkdir -p "$out/share/licenses"
      cp -R ${tui}/share/licenses/. "$out/share/licenses/"
      cp -R ${helper}/share/licenses/. "$out/share/licenses/"
    ''
