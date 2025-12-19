# NUR

My personal [NUR](https://github.com/nix-community/NUR) repository.

**All packages here are pre-built binaries.** Because I don't like to compile by myself.

Only tested on x86_64-linux. Packages may work on aarch64 systems, but I'm not sure about that.

## How to use

1. Add the following to your flake inputs:
   ```nix
   nur = {
     url = "github:nix-community/NUR";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```
2. Add overlays to pkgs as you like (for me, I use the following config):
   ```nix
   let
     pkgs = import nixpkgs {
       inherit system;
       overlays = [
         nur.overlays.default
       ];
     };
   in
   lib.nixosSystem {
     inherit pkgs;
     # ......
   }
   ```
3. use packages in your config:
   ```nix
   {
     environment.systemPackages = [
       pkgs.nur.repos.lxl66566.git-simple-encrypt       # gnu by default
       pkgs.nur.repos.lxl66566.git-simple-encrypt.musl  # if you want musl and the package suppport musl
     ];
   }
   ```
4. use modules in your config:
   ```nix
   {
     imports = [
       pkgs.nur.repos.lxl66566.modules.fungi
     ];
     services.fungi = {
       enable = true;
       configFile = ...
     };
   }
   ```

## packages

<!-- prettier-ignore -->
| Name | Outputs | Description |
| --- | --- | --- |
| [audio-loudness-batch-normalize](https://github.com/lxl66566/audio-loudness-batch-normalize) | null, musl | Easy to use audio loudness batch normalization tool based on EBU R128, written in Rust |
| [fungi](https://github.com/enbop/fungi) | null | p2p tool cross platform |
| [git-simple-encrypt](https://github.com/lxl66566/git-simple-encrypt) | null, musl | Encrypt/decrypt files in git repo using one password |
| [git-sync-backup](https://github.com/lxl66566/git-sync-backup) | null, musl | Synchronize and backup files/folders using Git, cross-device & configurable |
| [openppp2](https://github.com/liulilittle/openppp2) | null | Next-generation security network access technology, providing high-performance Virtual Ethernet tunneling service. |
| [system76-scheduler-niri](https://github.com/lxl66566/system76-scheduler-niri) | null, musl | Niri integration for system76-scheduler |
| [user-startup-rs](https://github.com/lxl66566/user-startup-rs) | null, musl | Simple cross-platform tool to make your command auto run on startup |
| [xp3-pack-unpack](https://github.com/lxl66566/xp3-pack-unpack) | null | kirikiri xp3 format cli packer & unpacker |

## modules

### system76-scheduler-niri

```nix
{
  services.system76-scheduler-niri.enable = true;
}
```

### fungi

not support attrSet config, since I don't use _fungi_ now... (currently using easytier.)

```nix
{
  services.fungi = {
    enable = true;
    # package = pkgs.nur.repos.lxl66566.fungi;  # this is the default package, you can also use your own package
    configFile = pkgs.writeText "test-config.toml" ''
      [rpc]
      listen_address = "127.0.0.1:5405"

      [network]
      listen_tcp_port = 0
      listen_udp_port = 0
      incoming_allowed_peers = [
        "16Uiu2HAmN7utr2gU28MizZqpL3tHtFK3nnPfxedzYVCLBxxCDWAP",
      ]
      disable_relay = false
      custom_relay_addresses = []

      [tcp_tunneling.forwarding]
      enabled = true
      rules = []

      [tcp_tunneling.listening]
      enabled = true
      rules = [
        { host = "127.0.0.1", port = 22 }, # Expose SSH to remote devices
      ]
    '';
    # or configFile = ./config.toml;
  };
}
```

## development

how to test packages/modules in this NUR:

```nix
nix-build -A openppp2               # build a package
nix-build tests/fungi-test.nix      # build a module
```
