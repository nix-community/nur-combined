# nur-packages

**Zerozawa's [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/lz37/nur/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-zerozawa-blue.svg)](https://zerozawa.cachix.org)

## Available Packages

### Manga/Comic Readers

| Package | Description | Features |
|---------|-------------|----------|
| `JMComic-qt` | 禁漫天堂 (18comic) PC client | Qt6, Vulkan GPU acceleration, waifu2x upscaling |
| `picacg-qt` | 哔咔漫画 (PicACG) PC client | Qt6, Vulkan GPU acceleration, waifu2x upscaling |

### SR Vulkan (Super Resolution)

| Package | Description |
|---------|-------------|
| `sr-vulkan` | Vulkan-based super resolution library (v2.0.1.1) |
| `sr-vulkan-model-waifu2x` | waifu2x models for sr-vulkan |
| `sr-vulkan-model-realcugan` | realcugan models for sr-vulkan |
| `sr-vulkan-model-realesrgan` | realesrgan models for sr-vulkan |
| `sr-vulkan-model-realsr` | realsr models for sr-vulkan |

### Other Tools

| Package | Description |
|---------|-------------|
| `Fladder` | Jellyfin client |
| `StartLive` | Bilibili live streaming tool |
| `bilibili_live_tui` | Bilibili live TUI client |
| `mihomo-smart` | Mihomo (Clash.Meta) with smart configuration |
| `wechat-web-devtools-linux` | WeChat Mini Program DevTools |
| `fortune-mod-zh` | Chinese fortune cookies |
| `fortune-mod-hitokoto` | Hitokoto (一言) fortune |
| `mikusays` | Miku-themed quotes |
| `waybar-vd` | Waybar with custom configuration |
| `sddm-eucalyptus-drop` | SDDM theme |
| `zsh-url-highlighter` | Zsh URL syntax highlighting |

## Usage

### Using NUR

```nix
# In your configuration.nix or home.nix
{
  imports = [
    (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz")
  ];

  environment.systemPackages = with pkgs.nur.repos.zerozawa; [
    JMComic-qt
    picacg-qt
    sr-vulkan
    # ... other packages
  ];
}
```

### Building Packages

```bash
# Build a specific package
nix-build -A JMComic-qt
nix-build -A picacg-qt
nix-build -A sr-vulkan

# Build all packages
nix-build ci.nix -A cacheOutputs
```

### Using with Flakes

```nix
{
  inputs.nur.url = "github:nix-community/NUR";

  outputs = { self, nixpkgs, nur }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { nixpkgs.overlays = [ nur.overlay ]; }
        {
          environment.systemPackages = with pkgs.nur.repos.zerozawa; [
            JMComic-qt
            picacg-qt
          ];
        }
      ];
    };
  };
}
```

## SR Vulkan Notes

The `sr-vulkan` package supports multiple upscaling models:
- **waifu2x**: Best for anime/manga art
- **realcugan**: Alternative anime upscaler
- **realesrgan**: General purpose upscaler
- **realsr**: Another general purpose upscaler

Models are automatically linked when using `JMComic-qt` or `picacg-qt`. For custom use:

```nix
with pkgs.nur.repos.zerozawa; [
  (sr-vulkan.override { sr-vulkan-models = [ sr-vulkan-model-waifu2x ]; })
]
```

## Binary Cache

This repository is built and cached via Cachix:

```bash
# Add the cache
nix run nixpkgs#cachix -- use zerozawa

# Or manually configure
nix.settings.substituters = [ "https://zerozawa.cachix.org" ];
nix.settings.trusted-public-keys = [ "zerozawa.cachix.org-1:9jPl+Xq6S4va32gPNJXTApDafDUwa5zjgFX65QfJ1CQ=" ];
```

## License

See individual package definitions for license information.
