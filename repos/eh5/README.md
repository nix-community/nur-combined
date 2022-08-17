# EHfive's Nix flakes

## Usage

### Setup cache (optional)

```bash
$ cachix use eh5
```

or add to NixOS config

```nix
{ ... } : {
  nix.settings.substituters =  [ "https://eh5.cachix.org" ];
  nix.settings.trusted-public-keys = [ "eh5.cachix.org-1:pNWZ2OMjQ8RYKTbMsiU/AjztyyC8SwvxKOf6teMScKQ=" ];
}
```

### Build/Run package

```
$ nix run   github:EHfive/flakes#netease-cloud-music
$ nix build github:EHfive/flakes#packages.aarch64-linux.ubootNanopiR2s
```

### Install package, module

<details>
<summary>NixOS (flake)</summary>

```nix
# flake.nix
{
  inputs.eh5 = {
    url = "github:EHfive/flakes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, eh5 }: {
    nixosConfigurations.your-machine = nixpkgs.lib.nixosSystem rec {
      # system = ...
      modules = [
        # ...
        #eh5.nixosModules.mosdns,
        #eh5.nixosModules.v2ray-next,
        { pkgs, ... }: {
          nixpkgs.overlays = [
            # ...
            eh5.overlays.default
            #eh5.overlays.v2ray-rules-dat
          ];

          environment.systemPackages = [
            pkgs.netease-cloud-music # via overlay
            # or specify the package directly
            #eh5.packages.${system}.netease-cloud-music
          ];
        }
      ];
    };
  };
}
```

All packages in this repo are also re-exported into [github:nixos-cn/flakes](https://github.com/nixos-cn/flakes), you can install from it in same fashion as above.

```
$ nix run github:nixos-cn/flakes#re-export.netease-cloud-music
$ # or in full path
$ nix run github:nixos-cn/flakes#legacyPackages.x86_64-linux.re-export.netease-cloud-music
```

</details>

## packages

| Name                    | Description                                                            | Platforms     |
| ----------------------- | ---------------------------------------------------------------------- | ------------- |
| fake-hwclock            | Fake hardware clock                                                    | \*            |
| mosdns                  | A DNS proxy                                                            | \*            |
| nix-gfx-mesa            | [nixGL](https://github.com/guibou/nixGL) but for Mesa only             | \*            |
| netease-cloud-music     | (no bundled libs, fixes FLAC playback and IME input)                   | x86_64-linux  |
| qcef                    | Qt5 binding of CEF                                                     | x86_64-linux  |
| ubootNanopiR2s          | U-Boot images for NanoPi R2S                                           | aarch64-linux |
| v2ray-next              | V2Ray v5                                                               | \*            |
| v2ray-rules-dat-geoip   | See [v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat) | \*            |
| v2ray-rules-dat-geosite | ditto                                                                  | \*            |

## overlays

### `.#overlays.default`

Adds all packages listed above.

### `.#overlays.v2ray-rules-dat`

Overrides `v2ray-geoip` and `v2ray-rules-dat-geosite` with `v2ray-rules-dat-geoip` and `v2ray-rules-dat-geosite` respectively.

## nixosModules

| Module                  | Description                   | Option                           | Type           |
| ----------------------- | ----------------------------- | -------------------------------- | -------------- |
| fake-hwclock            | Fake hardware clock service   | `services.fake-hwclock.enable`   | boolean        |
| mosdns                  | mosdns service                | `services.mosdns.enable`         | boolean        |
|                         |                               | `services.mosdns.config`         | YAML value     |
|                         |                               | `services.mosdns.configFile`     | string \| null |
| system-tarball-extlinux | `config.system.build.tarball` |                                  |                |
| v2ray-next              | V2Ray v5 service              | `services.v2ray-next.enable`     | boolean        |
|                         |                               | `services.v2ray-next.config`     | JSON value     |
|                         |                               | `services.v2ray-next.configFile` | string \| null |

Some of the modules requires some packages declared above, hence requiring `.#overlays.default` to be applied.
