![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)
![state](https://img.shields.io/badge/works-on%20my%20machines-FEDFE1)
![CI state](https://github.com/oluceps/nixos-config/actions/workflows/lint.yaml/badge.svg)
![CI state](https://github.com/oluceps/nixos-config/actions/workflows/sensitive.yaml/badge.svg)  

# Nix flake

This repo contains declaritive NixOS configurations, with ~100% config Nixfied.
> [!IMPORTANT]
> Public credentials placing in `hosts/lib.nix`. Make sure to replace'em if working with this repo.


with:

+ layout: [flake-parts](https://github.com/hercules-ci/flake-parts)
+ secret management: [agenix](https://github.com/ryantm/agenix) [rekey](https://github.com/oddlama/agenix-rekey)
+ secure boot: [lanzaboote](https://github.com/nix-community/lanzaboote)
+ root on tmpfs: [impermanence](https://github.com/nix-community/impermanence)
+ [home-manager](https://github.com/nix-community/home-manager)
+ Partition [disko](https://github.com/nix-community/disko)
+ command runner: [Just](https://github.com/casey/just) 

---

### Binary Cache

```nix
nix.settings = {
  substituers = ["https://nur-pkgs.cachix.org"];
  trusted-public-keys = [
    "nur-pkgs.cachix.org-1:PAvPHVwmEBklQPwyNZfy4VQqQjzVIaFOkYYnmnKco78="
  ];
};
```


## References

Excellent configurations that I've learned and copied:  
+ [NickCao/flakes](https://github.com/NickCao/flakes)  
+ [ocfox/nixos-config](https://github.com/ocfox/nixos-config)  
+ [Clansty/flake](https://github.com/Clansty/flake)  
+ [fufexan/dotfiles](https://github.com/fufexan/dotfiles)  
+ [gvolpe/nix-config](https://github.com/gvolpe/nix-config)
