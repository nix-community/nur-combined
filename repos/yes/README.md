Here are some additional nix packages for my personal use.

Package list: https://nur.nix-community.org/repos/yes/

Currently, this repository is updated manually. If you notice any outdated packages or packaging errors, feel free to open an [issue](https://github.com/SamLukeYes/nix-custom-packages/issues).
### What is the argument `rp`?
You may notice that most of the packages (all except `nodePackages`) in this repo accept an argument `rp`. This is a short term of reverse proxy. If you have trouble downloading sources, a reverse proxy might help. With the `rp` argument, you can easily pass the URL prefix of the reverse proxy to the package without overriding the whole `src`. To pass an `rp` value to all the packages that accept this argument in this repo, you can use an overlay like this:

```nix
final: prev: with prev;

let rp = "https://example.com/rp/"; in {
  nur = import (builtins.fetchTarball 
    "${rp}https://github.com/nix-community/NUR/archive/master.tar.gz"
  ) rec {
    pkgs = prev;
    repoOverrides = {
      yes = import (builtins.fetchTarball 
        "${rp}https://github.com/SamLukeYes/nix-custom-packages/archive/main.tar.gz"
      ) { inherit pkgs rp; };
    };
  };
}
```

An example reverse proxy that can be deployed on cloudflare workers: https://gitlab.com/NickCao/experiments/-/blob/master/workers/r.js
### Arch Linux packages

See [wiki](https://github.com/SamLukeYes/nix-custom-packages/wiki/Arch-Linux-packages) for details.

### Flakes?
Not yet... maybe until nix flake becomes a stable feature :p