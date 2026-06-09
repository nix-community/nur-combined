

# Start from bootstrap

According the file @./mod/hosts/bootstrap , construct a new machine config, you needs to do following:

first of all, asking me about the hostname of new machine,
in mod/disko , create a new file with that hostname with nix suffix, reference to other files and strictly following the disko config that bootstrap.nix file defines.

modify mod/age.nix to add new machine vaultix config, add new host config to mod/hosts/* , mod/bird/* , mod/net.nix; reference to other files in same directory.

new machine needs to enable yggdrasil and vxlan-mesh (reference to existing config)

## supplement info

- **Node Registry:** New machines MUST be added to `registry.toml` with a unique `id`, `mac`, `addrs` (IPv6), `ssh_key`, and `ygg_pubkey`. If `ygg_pubkey` is unknown, leave it as an empty string.
- **Constant Mapping:** Add the hostname to the `hosts` attribute set in `mod/constant.nix` (e.g., `hostname = sum;`) to expose it to the network-wide host list.
- **Module Convention:** Register host-specific configurations as modules using the `flake.modules.nixos."type/hostname"` pattern (e.g., `net/azasos`, `age/azasos`, `bird/azasos`).
- **Disko Module:** Register the Disko config as a module `disko/hostname` in `mod/disko/hostname.nix` and import it into the host configuration via `self.modules.nixos."disko/hostname"`.
- **Production Standards:** 
    - Apply `nixpkgs.overlays = [ self.overlays.default ];`.
    - Use `boot.kernelPackages = pkgs.linuxPackages_latest;`.
    - Configure `alloy` for log scraping (copy the standard journal scraping block for `sshd` and `sudo` from existing hosts).
- **Identity:** Ensure `identity.user` is correctly set (e.g., `"riro"`).
