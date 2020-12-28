# nur-packages
Personal NUR repository.  
Issues: https://todo.sr.ht/~noneucat/noneucat

## How to use

More information: https://github.com/nix-community/NUR  

- Add the NUR to your `packageOverrides`:
```
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```
- Use the packages/modules below in your configuration.
```
{ ... }: 

{
  # packages
  environment.systemPackages = [
    nur.repos.noneucat.sfeed
  ];
  
  # modules
  imports = [
    nur.repos.noneucat.modules.pinephone.sxmo  
  ];
}
```
- (you may need to add this repo to `repoOverrides` if the NUR hasn't been
  updated with the latest from this repo)

## Contents
- **modules/pinephone:** PinePhone-specific modules.
    - **sxmo:** Sxmo mobile UI. Activate using
      `services.xserver.windowManager.sxmo.enable`.
- **pkgs/codemadness-frontends:** Front-ends for some sites.
- **pkgs/ffmpeg-full-cuda:** FFmpeg, but with some extra CUDA flags.
- **pkgs/immersed:** Immersed VR agent for Linux.
- **pkgs/immersed-cuda:** Immersed, but patched with `ffmpeg-full-cuda`.
- **pkgs/sfeed:** Simple RSS and Atom parser.
- **pkgs/pinephone:** PinePhone-specific pakages.
    - **megapixels:** Camera app. Copy of https://github.com/NixOS/nixpkgs/pull/98479 .
    - **sxmo:** Sxmo-specific packages. 

