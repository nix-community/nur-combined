# NixOS Configuration

## Contents
- Execution context and option verification
- Flakes structure
- Module system
- Most common configuration elements
- Package management
- User management
- Networking
- Services and systemd
- Secret management
- Nix store and GC
- Overlays

---

## Execution Context and Option Verification

### Where commands run matters

Verification commands behave differently depending on the machine type. Refer to the full setup matrix in `SKILL.md`. Quick reference:

| Machine | Best verification method |
|---|---|
| NixOS host | `nixos-option <path>` or `man configuration.nix` |
| macOS / Linux with Nix (no NixOS) | `nix eval` or `search.nixos.org/options` |
| Any machine | `search.nixos.org/options` (always works) |

**Save your NixOS host address for quick SSH verification:**
```bash
# From macOS or non-NixOS Linux — run nixos-option remotely
ssh root@nixos-host nixos-option services.openssh.settings
ssh root@nixos-host man configuration.nix | grep -A3 "PasswordAuthentication"
```

### Verifying options before use

**Method 1: nixos-option (on NixOS host)**
```bash
# Check option exists and see its type, default, description
nixos-option services.openssh.settings
nixos-option networking.firewall.allowedTCPPorts
nixos-option boot.loader.systemd-boot.configurationLimit
```

**Method 2: search.nixos.org (any machine)**
- Go to `https://search.nixos.org/options`
- Select the correct channel (match your `nixpkgs.url`, e.g. `nixos-26.05`)
- Search the option name — shows exact path, type, default, and since which version

**Method 3: nix eval (on NixOS host or machine with nixpkgs)**
```bash
# Check if an option path exists in current nixpkgs
nix eval --impure --expr '(import <nixpkgs/nixos> {}).options.services.openssh.settings'
```

**Method 4: NixOS source (any machine with internet)**
```bash
# Find option definition in nixpkgs source
gh search code "PasswordAuthentication" --repo NixOS/nixpkgs --extension nix
```

### Version drift — options that changed between releases

Some commonly confused renames:

| Old (pre-23.05) | New (23.05+) |
|---|---|
| `services.openssh.passwordAuthentication` | `services.openssh.settings.PasswordAuthentication` |
| `services.openssh.permitRootLogin` | `services.openssh.settings.PermitRootLogin` |
| `services.openssh.kbdInteractiveAuthentication` | `services.openssh.settings.KbdInteractiveAuthentication` |
| `networking.useDHCP` (global) | per-interface or `networking.interfaces.*.useDHCP` |

**Rule:** If an option was valid before 23.05 but produces warnings now — check `search.nixos.org` for the current path.

---

## Flakes Structure

### Minimal flake.nix

```nix
{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";  # avoid duplicate nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  {
    nixosConfigurations.myhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/myhostname/configuration.nix
        ./hosts/myhostname/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.myuser = import ./home/myuser.nix;
        }
      ];
    };
  };
}
```

### Recommended directory layout

```
flake.nix
flake.lock
hosts/
  myhostname/
    configuration.nix
    hardware-configuration.nix
home/
  myuser.nix
modules/
  nixos/          # reusable NixOS modules
  home-manager/   # reusable HM modules
overlays/
pkgs/             # custom packages
secrets/
  secrets.nix     # agenix public key declarations
  *.age           # encrypted secret files
```

### Updating inputs

```bash
nix flake update              # update all inputs
nix flake update nixpkgs      # update single input
nix flake check               # validate before deploying
git add flake.lock            # always commit lock file
```

**Critical**: All files must be `git add`ed — untracked files are invisible to Nix.

### Variant: nixpkgs weekly cooldown (supply chain buffer)

Optional alternative to tracking a channel directly. The `nixpkgs-weekly` mirror applies a
seven-day cooldown — it deliberately waits a week before adopting new Nixpkgs commits, leaving
time for a compromised or broken package to be spotted before it reaches your machine. This
matters because Nixpkgs maintainers can merge their own PRs without peer review, and supply
chain attacks usually succeed within hours or days. See
[Determinate Systems: nixpkgs cooldown](https://determinate.systems/blog/nixpkgs-cooldown/).

This is a variant, not a requirement — use it when you want the extra buffer and accept lagging
upstream by a week. Swap the `nixpkgs` input URL:

```nix
inputs = {
  # rolling, with 7-day cooldown
  nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";

  # or pinned to a release, with cooldown (example: 26.05)
  # nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-26.05-chilled/0.1";
};
```

Everything else (the `follows`, the `nixosSystem` call) stays the same. The cooldown is already
on by default for Determinate Nix users and for the bare `nixpkgs` flake registry entry, so you
only need this when you pin the input explicitly.

### Variant: Determinate Secure Packages (enterprise, paid)

A curated Nixpkgs 26.05 package set (~10K packages) with enterprise supply-chain guarantees,
sold by Determinate Systems. Goes beyond the cooldown buffer: SLA-backed CVE remediation,
cryptographically signed packages, full binary cache coverage via FlakeHub Cache, and a
`flakebom` CLI that emits a CycloneDX SBOM. An optional FIPS variant ships compliant crypto
(OpenSSL, GnuTLS). Drop-in — swap the `nixpkgs` input:

```nix
inputs = {
  # curated + signed + SLA (requires a Determinate subscription)
  nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/secure-packages-26.05/0";

  # or the FIPS-compliant variant
  # nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/secure-packages-26.05-fips/0";
};
```

Use this only when you need commercial support/compliance (SLA, SBOM, FIPS, signatures). For a
free supply-chain buffer, the cooldown mirror above is enough. See
[Determinate Systems: Secure Packages 26.05](https://determinate.systems/blog/determinate-secure-packages-26-05/).

### Using two nixpkgs (stable + unstable)

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
};

outputs = { self, nixpkgs, nixpkgs-unstable, ... }: {
  nixosConfigurations.myhostname = nixpkgs.lib.nixosSystem {
    specialArgs = {
      pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
    };
    modules = [ ./configuration.nix ];
  };
};

# In configuration.nix — access via function args:
{ pkgs, pkgs-unstable, ... }: {
  environment.systemPackages = [
    pkgs.vim                    # from stable
    pkgs-unstable.neovim        # from unstable
  ];
}
```

---

## Module System

### Module structure

```nix
{ config, pkgs, lib, ... }:
let
  cfg = config.myService;   # convention: avoid repeating config.myService.xxx
in {
  imports = [ ./other-module.nix ];

  options.myService = {
    enable = lib.mkEnableOption "my service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.myservice = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.myservice}/bin/myservice --port ${toString cfg.port}";
    };
  };
}
```

### Key lib functions

| Function | Use |
|---|---|
| `lib.mkDefault value` | Set a default, easily overridden (priority 1000) |
| `lib.mkForce value` | Override all other definitions (priority 50) |
| `lib.mkIf cond value` | Conditional config — use instead of bare `if` |
| `lib.mkEnableOption "desc"` | Declare `enable = false` boolean option |
| `lib.mkMerge [ ... ]` | Explicitly merge multiple config sets |
| `lib.mkBefore list` | Prepend to list-type options |
| `lib.mkAfter list` | Append to list-type options |
| `lib.types.port` | Integer 1–65535 |
| `lib.types.str` | String |
| `lib.types.listOf lib.types.str` | List of strings |
| `lib.types.attrsOf lib.types.str` | Attribute set of strings |

**Always use `lib.mkIf`** (not bare `if`) when conditioning on `config.*` values — bare `if` causes infinite recursion.

### Passing data between modules via specialArgs

```nix
# flake.nix
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; username = "myuser"; };
  modules = [ ./configuration.nix ];
};

# configuration.nix
{ config, pkgs, username, ... }: {
  users.users.${username}.isNormalUser = true;
}
```

---

## Most Common Configuration Elements

### Boot

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.systemd-boot.configurationLimit = 10;
boot.loader.efi.canTouchEfiVariables = true;
boot.kernelPackages = pkgs.linuxPackages_latest;
```

### Packages

```nix
environment.systemPackages = with pkgs; [
  vim git wget curl htop
];
```

### Users

```nix
users.mutableUsers = false;   # fully declarative (recommended for servers)
users.users.myuser = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" "docker" ];
  hashedPasswordFile = config.age.secrets.myuser-password.path;
  openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  shell = pkgs.zsh;
};
```

Generate hashed password: `mkpasswd -m sha-512`

### Networking

```nix
networking.hostName = "mymachine";
networking.hostId = "12345678";   # required for ZFS: head -c 8 /etc/machine-id

# Static IP
networking.interfaces.eth0.ipv4.addresses = [{
  address = "192.168.1.10";
  prefixLength = 24;
}];
networking.defaultGateway = { address = "192.168.1.1"; interface = "eth0"; };
networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

# Dynamic IP (desktop/laptop)
networking.networkmanager.enable = true;

# Firewall
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPorts = [ 51820 ];  # WireGuard
};
```

### SSH

```nix
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
    KbdInteractiveAuthentication = false;
  };
};
```

### Timezone and locale

```nix
time.timeZone = "Europe/Warsaw";
i18n.defaultLocale = "pl_PL.UTF-8";
i18n.extraLocaleSettings.LC_TIME = "pl_PL.UTF-8";
console.keyMap = "pl";
```

### Systemd services

```nix
systemd.services.myapp = {
  description = "My application";
  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    User = "myapp";
    Group = "myapp";
    ExecStart = "${pkgs.myapp}/bin/myapp";
    Restart = "on-failure";
    EnvironmentFile = config.age.secrets.myapp-env.path;
    # Hardening (optional):
    DynamicUser = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ReadWritePaths = [ "/var/lib/myapp" ];
  };
};
```

---

## Secret Management

### Agenix

```nix
# secrets/secrets.nix (used only by agenix CLI, not imported by NixOS)
let
  host1 = builtins.readFile ./host1_ed25519_key.pub;
  admin = "ssh-ed25519 AAAA...admin-key...";
in {
  "dbpassword.age".publicKeys = [ host1 admin ];
}
```

```bash
cd secrets && agenix -e dbpassword.age   # create/edit
agenix -r                                 # re-key all
```

```nix
# configuration.nix
imports = [ agenix.nixosModules.default ];
age.secrets.dbpassword = {
  file = ./secrets/dbpassword.age;
  owner = "myservice";
  mode = "0400";
};
services.mydb.passwordFile = config.age.secrets.dbpassword.path;
```

### sops-nix

```nix
sops.defaultSopsFile = ./secrets/secrets.yaml;
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
sops.secrets.dbpassword = {};
sops.secrets."config/apikey" = { owner = "myservice"; };
```

**Choose agenix** for simple SSH key workflow. **Choose sops-nix** for cloud KMS, templating, or multiple secret formats.

---

## Nix Store Maintenance

```nix
# Automatic GC
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};

# Deduplicate store (hardlinks)
nix.optimise = {
  automatic = true;
  dates = [ "03:45" ];
};

# GC when disk is low
nix.extraOptions = ''
  min-free = ${toString (500 * 1024 * 1024)}
  max-free = ${toString (2 * 1024 * 1024 * 1024)}
'';
```

### Binary caches

```nix
nix.settings = {
  substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  trusted-users = [ "root" "@wheel" ];
  experimental-features = [ "nix-command" "flakes" ];
};
```

---

## Overlays

```nix
# overlay.nix — use prev (not final) when overriding existing packages
final: prev: {
  hello = prev.hello.overrideAttrs (old: {
    patches = old.patches ++ [ ./my-hello.patch ];
  });
  myTool = prev.callPackage ./pkgs/my-tool { };
}

# In configuration.nix:
nixpkgs.overlays = [ (import ./overlays/overlay.nix) ];
```

Use `prev` when overriding to prevent infinite recursion. Use `final` when a new package depends on another overlaid package.
