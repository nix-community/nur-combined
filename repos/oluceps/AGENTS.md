# Project Architecture & Directory Guide

This repo is public repo, should not contain any plaintext secret.

This repository uses a highly modular, `flake-parts` and `import-tree` driven NixOS configuration designed for a distributed cluster. To save time exploring the codebase, understand the following data flows and auto-wiring mechanics:


## Data Flow & Central Source of Truth
1. **`registry.toml`**: The absolute source of truth for the cluster. It defines node IDs, MAC addresses, IPv6 `addrs`, `ssh_key`s, and `ygg_pubkey`s.
2. **`mod/constant.nix`**: Reads `registry.toml` and exposes it cluster-wide via `config.data.node` and `config.data.hosts`. It also provides utility functions via `config.fn` (e.g., `config.fn.genCredPath`).
3. **`mod/os.nix`**: The configuration compiler. It iterates over all hosts defined in `os.<hostname>.module` (from `mod/hosts/*.nix`) and passes them to `nixosSystem`. 
   - **AUTO-WIRING (CRITICAL):** `mod/os.nix` *automatically* imports `age/<hostname>`, `net/<hostname>`, `disko/<hostname>`, `backup/<hostname>`, `caddy/<hostname>`, and `bird/<hostname>` if they exist in `flake.modules.nixos`. **Do NOT explicitly import these in `mod/hosts/<hostname>.nix`**, as it will cause `duplicate definition` build errors.

## Directory Map & Module Locations

### `/mod/` (Core Flake Modules)
Configurations here are structured as `flake.modules.nixos."<name>"`.
- **`mod/hosts/*.nix`**: The entrypoint for each machine. Defines `os.<hostname>.module`. Explicitly imports general shared modules (e.g., `base`, `dev`, `vxlan-mesh`, `prometheus`) but relies on `os.nix` for host-specific networking/secrets.
- **`mod/net.nix`**: Contains network definitions for *all* hosts formatted as `flake.modules.nixos."net/<hostname>"`. Defines MAC matching, IPv6 routing, and firewall rules via `systemd.network`.
- **`mod/age.nix`**: Contains secret definitions for *all* hosts formatted as `flake.modules.nixos."age/<hostname>"`. Relies on the `vaultix` module.
- **`mod/disko/*.nix`**: Dedicated files for disk layouts. Exported as `flake.modules.nixos."disko/<hostname>"`.
- **`mod/bird/*.nix` & `mod/caddy/*.nix`**: Dedicated files for routing (BGP/babel) and reverse proxy configurations per host. Exported as `flake.modules.nixos."bird/<hostname>"` and `"caddy/<hostname>"`.
- **`mod/custom-modules.nix`**: Imports all standalone services from `/nixosModules/` and exposes them as `flake.nixosModules.default`.
- **`mod/shared-modules.nix`**: Imports `self` (which pulls in the default `nixosModules`) and external modules like `nix-topology`.

### `/nixosModules/` (Custom Services)
Contains standalone NixOS modules (e.g., `metrics.nix`, `sing-box.nix`, `factorio.nix`). 
- **Rule of Thumb:** If a module here configures another service (e.g., `metrics.nix` modifying `caddy.settings`), it **MUST** be wrapped in `lib.mkIf (config.serviceName ? settings)` to prevent `attribute missing` errors on hosts that don't enable that service.

## Common Pitfalls for Agents
1. **Missing `caddy` attribute:** If a shared module references `config.caddy`, the build will fail on hosts without a `caddy/<hostname>` module unless conditionally checked.
2. **Duplicate Disko/Net definitions:** As stated in Auto-Wiring, do not `(import ../disko/hostname.nix)` inside the host file. Let `os.nix` handle it.
3. **Missing `inputs` error:** Make sure flake inputs are passed correctly if adding new top-level evaluators. Use existing patterns for overrides.
4. **UID Conflict (Userborn):** If changing users on an existing disk, `userborn` may fail due to UID 1000 being occupied. See `docs/troubleshooting/2026-06-11-uid-conflict-userborn.md` for the fix.

# Start from bootstrap

According the file @./mod/hosts/bootstrap , construct a new machine config, you needs to do following:

first of all, asking me about the hostname of new machine,
in mod/disko , create a new file with that hostname with nix suffix, reference to other files and strictly following the disko config that bootstrap.nix file defines.

modify mod/age.nix to add new machine vaultix config, add new host config to mod/hosts/* , mod/bird/* , mod/net.nix; reference to other files in same directory.

new machine needs to enable yggdrasil and vxlan-mesh (reference to existing config)

## supplement info

- **Node Registry:** New machines MUST be added to `registry.toml` with a unique `id`, `mac`, `addrs` (IPv6), `ssh_key`, and `ygg_pubkey`. If `ygg_pubkey` is unknown, leave it as an empty string. 
    - **VPS Specifics:** If the machine is a VPS, you MUST ask for `iata` (Airport code, e.g., "NRT") and `city` (e.g., "Tokyo") to add to the registry entry.
- **Constant Mapping:** Add the hostname to the `hosts` attribute set in `mod/constant.nix` (e.g., `hostname = sum;`) to expose it to the network-wide host list.
- **Module Convention:** Register host-specific configurations as modules using the `flake.modules.nixos."type/hostname"` pattern (e.g., `net/azasos`, `age/azasos`, `bird/azasos`).
- **Disko Module:** Register the Disko config as a module `disko/hostname` in `mod/disko/hostname.nix` and import it into the host configuration via `self.modules.nixos."disko/hostname"`.
- **Production Standards:** 
    - Apply `nixpkgs.overlays = [ self.overlays.default ];`.
    - Use `boot.kernelPackages = pkgs.linuxPackages_latest;`.
    - Configure `alloy` for log scraping (copy the standard journal scraping block for `sshd` and `sudo` from existing hosts).
- **Identity:** Ensure `identity.user` is correctly set (e.g., `"riro"`).
