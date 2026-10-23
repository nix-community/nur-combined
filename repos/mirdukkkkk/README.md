# honeycomb

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build and populate cache](https://github.com/mirdukkkkk/honeycomb/actions/workflows/build.yml/badge.svg)](https://github.com/mirdukkkkk/honeycomb/actions/workflows/build.yml)
[![Update sources](https://github.com/mirdukkkkk/honeycomb/actions/workflows/update.yml/badge.svg)](https://github.com/mirdukkkkk/honeycomb/actions/workflows/update.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-mirdukkkkk-blue.svg)](https://mirdukkkkk.cachix.org)

> [!WARNING]
> **Bleeding edge.** Everything here is built against `nixpkgs-unstable`, and sources are
> bumped automatically every day: `flake.lock` and the Firefox add-ons are regenerated
> and pushed by CI without manual review. A package can break or change between two
> evaluations. Pin this repository to a known-good revision if you need stability.

## Packages

| Attribute | Description |
| --- | --- |
| `beefetch` | Neofetch clone written in Go with the ability to display 🐝 ([mirdukkkkk/beefetch](https://github.com/mirdukkkkk/beefetch)) |
| `molten` | Protobuf-based stream format and renderer for collaborative pixel canvases ([pixelate-it/molten](https://github.com/pixelate-it/molten)) |
| `firefox-addons.cookie-editor` | View, edit and export cookies |
| `firefox-addons.flagfox` | Shows the server's country flag in the address bar (unfree) |
| `firefox-addons.indicatetls` | Shows the negotiated TLS version in the address bar |
| `firefox-addons.media-harvest` | Downloads images and videos from X/Twitter in original quality ([EltonChou/TwitterMediaHarvest](https://github.com/EltonChou/TwitterMediaHarvest)) |
| `firefox-addons.plasma-integration` | KDE Plasma browser integration (needs `plasma-browser-integration` as the native host) |
| `firefox-addons.preact-devtools` | Preact developer tools |
| `firefox-addons.reduxdevtools` | Redux developer tools |
| `firefox-addons.resourceoverride` | Override website resources with your own |
| `firefox-addons.sponsorblock` | Skips sponsor segments in YouTube videos |
| `firefox-addons.ublock-origin` | Content blocker |

The add-on list lives in [`pkgs/firefox-addons/addons.json`](./pkgs/firefox-addons/addons.json);
`generated.nix` is produced from it by
[mozilla-addons-to-nix](https://git.sr.ht/~rycee/mozilla-addons-to-nix).

`media-harvest` is not listed on AMO, so it is fetched from the signed `.xpi` in its
GitHub releases instead; its version and hash live in
[`pkgs/firefox-addons/media-harvest.json`](./pkgs/firefox-addons/media-harvest.json)
and are bumped by the same daily workflow. The add-on also updates itself from its
own server; set `extensions.update.enabled = false` in Firefox to let Nix pin it.

## Usage

### Through NUR

```nix
# with the NUR overlay applied
environment.systemPackages = [ pkgs.nur.repos.mirdukkkkk.molten ];

# home-manager
programs.firefox.profiles.default.extensions.packages =
  with pkgs.nur.repos.mirdukkkkk.firefox-addons; [ preact-devtools ];
```

### As a flake input

```nix
inputs.honeycomb.url = "github:mirdukkkkk/honeycomb";

# then
inputs.honeycomb.legacyPackages.${system}.molten
```

### Binary cache

Prebuilt packages are pushed to Cachix. Firefox add-ons are not cached, since they are
plain downloads.

```nix
nix.settings = {
  substituters = [ "https://mirdukkkkk.cachix.org" ];
  trusted-public-keys = [ "mirdukkkkk.cachix.org-1:DWyywfS24EqoOutAfzL+oL1SdrdBrG7SAtpNkG+xuvs=" ];
};
```

## License

The Nix expressions in this repository are [MIT](./LICENSE). Each package keeps the
license of its upstream project, see its `meta.license`.
