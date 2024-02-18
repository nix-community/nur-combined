![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)
![state](https://img.shields.io/badge/works-on%20my%20machines-FEDFE1)
![CI state](https://github.com/oluceps/nixos-config/actions/workflows/lint.yaml/badge.svg)
![CI state](https://github.com/oluceps/nixos-config/actions/workflows/sensitive.yaml/badge.svg)  

# Nix flake

This repo contains declaritive configurations, with ~100% config Nixfied.
> [!IMPORTANT]
> Authentication credentials placing in `hosts/lib.nix`. Make sure to replace'em if deploying with this repo.


with:

+ layout: [flake-parts](https://github.com/hercules-ci/flake-parts)
+ secret management with hardware key: [agenix](https://github.com/ryantm/agenix) [rekey](https://github.com/oddlama/agenix-rekey)
+ secure boot: [lanzaboote](https://github.com/nix-community/lanzaboote)
+ root on tmpfs states keeping: [impermanence](https://github.com/nix-community/impermanence)
+ Standalone [home-manager](https://github.com/nix-community/home-manager)
+ Partition declare with [disko](https://github.com/nix-community/disko)
+ command runner: [Just](https://github.com/casey/just) 

---


|Type|Program|
|---|---|
|Kernel|[cachyos-kernel](https://github.com/CachyOS/linux-cachyos)|
|Editor|[helix](https://github.com/oluceps/nixos-config/tree/main/home/programs/helix)|
|WM|[sway](https://github.com/oluceps/nixos-config/tree/main/home/programs/sway)|
|Bar|[waybar](https://github.com/oluceps/nixos-config/tree/main/home/programs/waybar)|
|Shell|[fish](https://github.com/oluceps/nixos-config/tree/main/home/programs/fish)|
|Terminal|[alacritty](https://github.com/oluceps/nixos-config/tree/main/home/programs/alacritty)|
|backup|[btrbk](https://github.com/oluceps/nixos-config/tree/main/modules/btrbk)|  

__Overlay & nixosModules__  

Contains overlay and modules of few packages,

Applying:  

```nix
# flake.nix
{
  inputs.oluceps.url = "github:oluceps/nixos-config";
  outputs = inputs: {
    nixosConfigurations.machine-name = {
    # ...
    modules = [
      # ...
      {
        nixpkgs.overlays = [ inputs.oluceps.overlay ];
        # packages in `pkgs` dir of this repo,
        # with pname consist with dir name
        environment.systemPackages = 
          [ pkgs.<?>
            inputs.oluceps.packages.${system}.foliate ];
      }

      inputs.oluceps.nixosModules.default
      # or any standalone module (see `nix flake show`)
    ];
  };
};
}
```



## References

Excellent configurations that I've learned and copied:  
+ [NickCao/flakes](https://github.com/NickCao/flakes)  
+ [ocfox/nixos-config](https://github.com/ocfox/nixos-config)  
+ [Clansty/flake](https://github.com/Clansty/flake)  
+ [fufexan/dotfiles](https://github.com/fufexan/dotfiles)  
+ [gvolpe/nix-config](https://github.com/gvolpe/nix-config)
