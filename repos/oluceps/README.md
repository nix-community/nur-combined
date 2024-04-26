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

## structure

```
.
├── age.nix       # agenix rekey config
├── ci.nix        # both for \n
├── default.nix   # compatible with nur repo check
├── flake.lock
├── flake.nix
├── fn
│   ├── alert.ts  # prometheus alert bridge for ntfy
│   └── f         # nushell module with some functions
├── home                
│   ├── default.nix     # home-manager nixos module toplevel
│   ├── graphBase.nix   # graphic settings
│   ├── home.nix        # general settings, optionally loads programs and graph config
│   └── programs (dir)
├── hosts
│   ├── default.nix     # colmena settings
│   ├── hastur (dir)    # machine, to run heavy task
│   ├── bootstrap (dir) # minimal config for bootstraping, no colmena
│   ├── resq (dir)      # minimal config for remote resuce, no colmena, with wireguard
│   ├── livecd (dir)    # livecd
│   ├── graphBase.nix   # general settings
│   ├── lib.nix         # common lib
│   ├── nodens (dir)    # server
│   ├── persist.nix     # impermanence settings, optional loaded by hosts
│   ├── secureboot.nix  # lanzaboote secureboot settings
│   ├── sysctl.nix      # sysctl
│   ├── sysvars.nix
│   └── ......          # other server config similar to nodens
├── justfile
├── LICENSE
├── misc.nix
├── modules (dir)       # nixosModules, autoload by flake, appended to nixosConfig defaultly
├── overlays.nix
├── packages.nix        # nixosConfig syswide global packages
├── pkgs (dir)          # packages, autoload by flake, append to overlay
├── sec (dir)           # agenix-rekey pubkeys, rekeyed secrets
├── srv (dir)           # wrapper beyound nixosModule `services.`, predefined service option for reuse
└── users.nix
```

#### srv

This is designed for easy play with more services and better reuse service config.

```
nixosModule option  predefined & repack   srv option
   services.${}             =>              srv.${}

srv.foo = {
  enable = true;
  override = {
    oldOption = "new"; # override option predefined in /srv/foo.nix
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
