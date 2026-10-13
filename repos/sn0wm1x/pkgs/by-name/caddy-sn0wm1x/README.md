# caddy-sn0wm1x

Caddy with plugins selected by SN0WM1X: forwardproxy, dns-cloudflare,
caddy-docker-proxy, caddy-l4, caddy-dynamicdns and caddy-webdav, plus the upstream
QUIC BBRv1 patch.

## Usage

```sh
nix run github:sn0wm1x/ur#caddy-sn0wm1x -- run --config ./Caddyfile
```

For Docker label discovery, grant access to the Docker API and run:

```sh
nix run github:sn0wm1x/ur#caddy-sn0wm1x -- docker-proxy --caddyfile-path ./Caddyfile
```

## NixOS

Add the flake input:

```nix
inputs.sn0wm1x.url = "github:sn0wm1x/ur";
inputs.sn0wm1x.inputs.nixpkgs.follows = "nixpkgs";
```

In your NixOS configuration, with `inputs` available through `specialArgs`:

```nix
services.caddy = {
  enable = true;
  package = inputs.sn0wm1x.packages.${pkgs.stdenv.hostPlatform.system}.caddy-sn0wm1x;
};
```

## Development

From the repository root:

```sh
nix build .#caddy-sn0wm1x
nix build .#caddy-sn0wm1x.tests.integration
nix shell nixpkgs#nix-update -c nix-update --flake --use-update-script caddy-sn0wm1x
```

To refresh hashes after updating nixpkgs:

```sh
python3 pkgs/by-name/caddy-sn0wm1x/update.py --hash-only
```
