# Attic binary cache with Podman

This deployment stores both the SQLite database and cache objects on the
server's local disk. It does not need S3 or a shared `/nix/store`.

## Build and run

Build with Podman from this directory:

```console
podman build --tag localhost/atticd .
```

The Dockerfile pulls `nixos/nix:2.34.8` through
`docker.xuanyuan.me`, so it does not connect to Docker Hub directly.

If the mirror is unavailable, build the same image directly with Nix from the
repository root:

```console
nix build .#attic-cache-image
podman load --input result
```

Create a persistent volume and a Podman secret containing the JWT signing
key:

```console
podman volume create attic-data
install -d -m 0700 "$HOME/.config/atticd"
SECRET="$(openssl rand -base64 48 | tr -d '\n')"
printf '%s' "$SECRET" > "$HOME/.config/atticd/token-hs256-secret"
chmod 0600 "$HOME/.config/atticd/token-hs256-secret"
podman secret create \
  attic-token-hs256 \
  "$HOME/.config/atticd/token-hs256-secret"
```

Install the Quadlet. It binds Attic to loopback, mounts `server.toml`, injects
the secret, and generates the independent `atticd.service`:

```console
install -d -m 0755 /etc/containers/systemd
install -m 0644 atticd.container /etc/containers/systemd/atticd.container
systemctl daemon-reload
systemctl start atticd.service
```

Install Caddy and its configuration:

```console
dnf install caddy
install -m 0644 Caddyfile /etc/caddy/Caddyfile
systemctl enable --now caddy.service
```

For the 3.5 GiB build host, install the persistent 12 GiB swap unit and
conservative Nix build limits:

```console
fallocate -l 12G /swapfile
chmod 0600 /swapfile
mkswap /swapfile
install -m 0644 swapfile.swap /etc/systemd/system/swapfile.swap
install -m 0644 90-swap.conf /etc/sysctl.d/90-swap.conf
install -m 0644 server-nix.conf /etc/nix/nix.conf
systemctl daemon-reload
systemctl enable --now swapfile.swap
sysctl --load /etc/sysctl.d/90-swap.conf
systemctl restart nix-daemon.service
```

## Create the first cache

Generate an administrator token:

```console
podman exec atticd atticadm \
  make-token \
  --config /etc/attic/server.toml \
  --sub admin \
  --validity 10y \
  --pull '*' \
  --push '*' \
  --delete '*' \
  --create-cache '*' \
  --configure-cache '*' \
  --configure-cache-retention '*' \
  --destroy-cache '*'
```

Install the client on any build machine and use the token printed above:

```console
nix profile install \
  --option substituters https://mirrors.cernet.edu.cn/nix-channels/store \
  nixpkgs#attic-client
attic login personal https://cache.mr-why.cn ADMIN_TOKEN
attic cache create nur
attic cache configure nur --public
```

Build and upload from either the workstation or the server:

```console
nix build github:silicalet/nur-packages-silicalet#amber-lsp
attic push nur ./result
```

`attic use nur` configures the current machine as a client. Alternatively,
copy the binary cache endpoint and public key shown by:

```console
attic cache info nur
```

The public substituter URL will be `https://cache.mr-why.cn/nur`.
Its public key is:

```text
nur:aQlY5sfibsfPJgLVG4yMCrJLB4+RJ1vaebK4sWl74K4=
```
