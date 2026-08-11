# NixOS Anti-Patterns

## Contents
- Nix language anti-patterns
- NixOS configuration anti-patterns
- Operational anti-patterns
- Quick diagnostic checklist

---

## Nix Language Anti-Patterns

### `nix-env -i` — Never use imperatively

```bash
# WRONG — bypasses declarative model, invisible to rebuilds
nix-env -i firefox

# RIGHT
environment.systemPackages = [ pkgs.firefox ];
```

### `rec { ... }` — Causes hard-to-debug infinite recursion

```nix
# WRONG
rec {
  a = 1;
  b = a + 1;   # innocent looking but rec is dangerous in larger sets
}

# RIGHT
let
  a = 1;
  b = a + 1;
in { inherit a b; }
```

### `with pkgs;` at file scope — Blocks static analysis

```nix
# WRONG — pollutes scope, hides where packages come from
with pkgs; {
  environment.systemPackages = [ vim git wget ];
}

# RIGHT — explicit
environment.systemPackages = with pkgs; [ vim git wget ];
# or fully explicit:
environment.systemPackages = [ pkgs.vim pkgs.git pkgs.wget ];
```

### `<nixpkgs>` lookup paths — Impure, non-reproducible

```nix
# WRONG — depends on NIX_PATH of the machine running the build
import <nixpkgs> {}

# RIGHT — flake input or pinned path
{ pkgs, ... }: { ... }   # pkgs comes from nixosSystem's nixpkgs
```

### `//` for nested updates — Shallow merge replaces entire subtree

```nix
# WRONG — replaces ALL of networking, not just hostName
config = oldConfig // { networking = { hostName = "new"; }; };

# RIGHT
config = lib.recursiveUpdate oldConfig { networking = { hostName = "new"; }; };
```

### Bare `if` on `config.*` values — Causes infinite recursion

```nix
# WRONG — infinite recursion if config.myOption depends on another module
config = if config.services.foo.enable then { ... } else { };

# RIGHT
config = lib.mkIf config.services.foo.enable { ... };
```

---

## NixOS Configuration Anti-Patterns

### Secrets in flake files — Nix store is world-readable

```nix
# WRONG — anyone with store access sees the password
users.users.myuser.password = "mysecret";
services.mydb.password = "dbsecret";

# RIGHT — use hashed password from secret file
users.users.myuser.hashedPasswordFile = config.age.secrets.myuser-pw.path;
```

### Changing `system.stateVersion` after install

```nix
# WRONG — breaks service state migrations, can corrupt databases
system.stateVersion = "26.05";  # changed from original "25.11"

# RIGHT — set once at install, never change
system.stateVersion = "25.11";  # original value, leave it
```

### Not limiting boot entries — `/boot` fills up silently

```nix
# WRONG — omitting this causes /boot to fill up over time
boot.loader.systemd-boot.enable = true;

# RIGHT
boot.loader.systemd-boot.enable = true;
boot.loader.systemd-boot.configurationLimit = 10;
```

### `mutableUsers = true` with impermanence — Users disappear on reboot

```nix
# WRONG when using impermanence — passwd changes vanish
users.mutableUsers = true;

# RIGHT — declare everything, set mutableUsers = false
users.mutableUsers = false;
users.users.myuser = {
  hashedPasswordFile = config.age.secrets.myuser-pw.path;
  ...
};
```

### No garbage collection — Nix store grows unboundedly

```nix
# WRONG — omitting this causes disk to fill with old generations
# (nothing)

# RIGHT
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};
```

### Missing `follows` for shared inputs — Multiple nixpkgs versions downloaded

```nix
# WRONG — home-manager pulls its own nixpkgs version
inputs.home-manager.url = "github:nix-community/home-manager";

# RIGHT
inputs.home-manager = {
  url = "github:nix-community/home-manager";
  inputs.nixpkgs.follows = "nixpkgs";  # reuse the same nixpkgs
};
```

### Using NixOps — Considered abandonware

```bash
# WRONG — NixOps is largely unmaintained
nixops deploy

# RIGHT — use one of:
# - nixos-rebuild --target-host  (simple, 1-3 machines)
# - deploy-rs                    (auto-rollback, small fleet)
# - colmena                      (large fleet, parallel)
```

---

## Operational Anti-Patterns

### `nixos-rebuild switch` directly over SSH — Can lock you out

```bash
# WRONG — if SSH or network config breaks, you lose access
nixos-rebuild switch --flake .#server --target-host root@server

# RIGHT — test first, only switch if it works
nixos-rebuild test --flake .#server --target-host root@server
# verify manually via SSH, then:
nixos-rebuild switch --flake .#server --target-host root@server
```

### Not using `--use-substitutes` on remote builds — Slow binary transfers

```bash
# WRONG — build host copies entire closure to target host
nixos-rebuild switch --target-host root@server

# RIGHT — target fetches from binary cache directly
nixos-rebuild switch --target-host root@server --use-substitutes
```

### Forgetting `git add` with flakes — New files silently ignored

```bash
# WRONG — new .nix file invisible to Nix, leads to confusing errors
vim hosts/newhost/configuration.nix
nixos-rebuild build --flake .#newhost
# Error: file not found (but file exists!)

# RIGHT
git add hosts/newhost/configuration.nix
nixos-rebuild build --flake .#newhost
```

### Deploying without dry-activate check first

```bash
# WRONG — applying changes without previewing
nixos-rebuild switch

# RIGHT — preview first
nixos-rebuild dry-activate --flake .#hostname
# review output, then:
nixos-rebuild test --flake .#hostname
```

### Not binding `/dev/disk/by-id/` — Device names change on reboot

```nix
# WRONG — /dev/sda can become /dev/sdb after adding a disk
disko.devices.disk.main.device = "/dev/sda";

# RIGHT — stable identifier
disko.devices.disk.main.device = "/dev/disk/by-id/ata-Samsung_SSD_...";
```

---

## Quick Diagnostic Checklist

When something doesn't work after `nixos-rebuild`:

```
[ ] Did you git add all new files?
[ ] Did you run nix flake check before applying?
[ ] Did you use nixos-rebuild test before switch?
[ ] Are secrets accessible? (check /run/agenix/ or /run/secrets/)
[ ] Check journalctl -u <service> for service errors
[ ] Check nixos-rebuild dry-activate output for unexpected changes
[ ] Is system.stateVersion correct for this machine?
[ ] If locked out: boot previous generation from bootloader menu
```

### Roll back after failed deploy

```bash
# Option 1: select previous generation at boot (GRUB/systemd-boot menu)

# Option 2: if you can still SSH
nixos-rebuild switch --rollback
# or activate a specific generation:
sudo /nix/var/nix/profiles/system-42-link/bin/switch-to-configuration switch
```
