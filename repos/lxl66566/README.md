# NUR

My personal [NUR](https://github.com/nix-community/NUR) repository.

**All packages here are pre-built binaries.**

## How to use

1. Add the following to your flake inputs:
   ```nix
   nur = {
     url = "github:nix-community/NUR";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```
2. Add the following to your `configuration.nix`:
   ```nix
   nixpkgs.overlays = [ nur.overlays.default ];
   ```
3. use packages in your config:
   ```nix
   {
     environment.systemPackages = with pkgs; [
       nur.repos.lxl66566.git-simple-encrypt
     ];
   }
   ```

## packages

<!-- prettier-ignore -->
| Name | Outputs | Description |
| --- | --- | --- |
| [audio-loudness-batch-normalize](https://github.com/lxl66566/audio-loudness-batch-normalize) | null, musl | Easy to use audio loudness batch normalization tool based on EBU R128, written in Rust |
| [git-simple-encrypt](https://github.com/lxl66566/git-simple-encrypt) | null, musl | Encrypt/decrypt files in git repo using one password |
| [git-sync-backup](https://github.com/lxl66566/git-sync-backup) | null, musl | Synchronize and backup files/folders using Git, cross-device & configurable |
| [openppp2](https://github.com/liulilittle/openppp2) | null | Next-generation security network access technology, providing high-performance Virtual Ethernet tunneling service. |
| [user-startup-rs](https://github.com/lxl66566/user-startup-rs) | null, musl | Simple cross-platform tool to make your command auto run on startup |
| [xp3-pack-unpack](https://github.com/lxl66566/xp3-pack-unpack) | null | kirikiri xp3 format cli packer & unpacker |
