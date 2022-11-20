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
        # imports all
        eh5.nixosModules.default
        # or on demand
        #eh5.nixosModules.mosdns
        #eh5.nixosModules.v2ray-next
        { pkgs, ... }: {
          nixpkgs.overlays = [
            # ...
            eh5.overlays.default
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

### Base

| Name                  | Description                                                | Platforms     |
| --------------------- | ---------------------------------------------------------- | ------------- |
| dovecot-fts-flatcurve | Dovecot FTS Flatcurve plugin (Xapian)                      | \*-linux      |
| fake-hwclock          | Fake hardware clock                                        | \*            |
| mosdns                | A DNS proxy                                                | \*            |
| nix-gfx-mesa          | [nixGL](https://github.com/guibou/nixGL) but for Mesa only | \*            |
| netease-cloud-music   | (no bundled libs, fixes FLAC playback and IME input)       | x86_64-linux  |
| qcef                  | Qt5 binding of CEF                                         | x86_64-linux  |
| stalwart-cli          | Stalwart JMAP server CLI                                   | \*            |
| stalwart-imap         | Stalwart IMAP server (imap-to-jmap proxy)                  | \*            |
| stalwart-jmap         | Stalwart JMAP server                                       | \*            |
| ubootNanopiR2s        | U-Boot images for NanoPi R2S                               | aarch64-linux |
| v2ray-next            | V2Ray v5                                                   | \*            |

### Extra

| Name                          | Description                                                                                           | Platforms              |
| ----------------------------- | ----------------------------------------------------------------------------------------------------- | ---------------------- |
| sops-install-secrets-nonblock | sops-install-secrets but using non-blocking [getrandom(2)](https://man.archlinux.org/man/getrandom.2) | {x86_64,aarch64}-linux |

## overlays

### `.#overlays.default`

Adds all base packages listed above.

## nixosModules

| Module                  | Description                                                                | Option                         |
| ----------------------- | -------------------------------------------------------------------------- | ------------------------------ |
| fake-hwclock            | Fake hardware clock service                                                | `services.fake-hwclock.enable` |
| mosdns                  | mosdns service                                                             | `services.mosdns.*`            |
| stalwart-jmap           | Stalwart JMAP server                                                       | `services.stalwart-jmap.*`     |
| system-tarball-extlinux | `config.system.build.tarball` for systems using EXTLINUX style boot loader | `system.enableExtlinuxTarball` |
| v2ray-next              | V2Ray v5 service                                                           | `services.v2ray-next.*`        |
| v2ray-rules-dat         | Auto update V2Ray rules dat                                                | `services.v2ray-rules-dat.*`   |
| default                 | Imports all above modules                                                  |                                |

Some of the modules requires some packages declared above, hence requiring `.#overlays.default` to be applied.
