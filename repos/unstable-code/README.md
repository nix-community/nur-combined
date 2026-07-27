# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/unstable-code/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Package | Description |
|---------|-------------|
| `upnote` | Cross-platform note-taking application (unfree, prebuilt .deb) |
| `wshowlyrics` | Wayland Lyrics Overlay inspired by LyricsX (stable) |
| `wshowlyrics-unstable` | Wayland Lyrics Overlay inspired by LyricsX (nightly) |

## Usage

Substitute `<package>` below with any attribute from the table above.

### With NUR (after registration)

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nur.repos.unstable-code.<package>
  ];
}
```

This route builds against **your own** nixpkgs, so your `nixpkgs.config` (including
`allowUnfree`) applies as you would expect. It works for every package here.

### With Flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-unstable-code.url = "github:unstable-code/nur-packages";
  };

  outputs = { self, nixpkgs, nur-unstable-code, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            nur-unstable-code.packages.${pkgs.system}.<package>
          ];
        })
      ];
    };
  };
}
```

> [!WARNING]
> `packages.<system>` does **not** work for unfree packages (currently `upnote`).
>
> This flake builds its package set with `import nixpkgs { inherit system; }` — no
> `allowUnfree`. An unfree package taken from there evaluates `.type`/`.version` fine, so it
> still shows up in `nix flake show`, but accessing `.outPath` throws. Setting
> `nixpkgs.config.allowUnfree = true` in *your* config does not help, because the derivation
> was already produced by this flake's nixpkgs instance — which is what the resulting error
> message unhelpfully suggests you do.
>
> Instantiate it consumer-side instead, which also avoids a second nixpkgs evaluation:

```nix
nixpkgs.overlays = [
  (final: prev: {
    upnote = final.callPackage "${nur-unstable-code}/pkgs/upnote" { };
  })
];
```
