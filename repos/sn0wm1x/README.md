<br />
<div align="center">
<img src="https://github.com/sn0wm1x.png" alt="sn0wm1x" />
</div>

<h1 align="center">SN0WM1X (Nix) User Repository</h1>

<div align="center">

**[<kbd> <br> Lib <br> </kbd>](/lib/)** 
**[<kbd> <br> Modules <br> </kbd>](/modules/)** 
**[<kbd> <br> Overlays <br> </kbd>](/overlays/)** 
**[<kbd> <br> Packages <br> </kbd>](/pkgs/)**

</div>

---

![Build and populate cache](https://github.com/sn0wm1x/ur/workflows/Build%20and%20populate%20cache/badge.svg) [![Cachix Cache](https://img.shields.io/badge/cachix-sn0wm1x-blue.svg)](https://sn0wm1x.cachix.org)

## Usage

###### nix run

```bash
nix run github:sn0wm1x/ur#example-package
```

###### nix flake

```nix
home.packages = with pkgs; [
  nur-no-pkgs.repos.sn0wm1x.example-package
];
```

## License

[MIT](/LICENSE.md)

<!-- # nur-packages-template

**A template for [NUR](https://github.com/nix-community/NUR) repositories**

## Setup

1. Click on [Use this template](https://github.com/nix-community/nur-packages-template/generate) to start a repo based on this template. (Do _not_ fork it.)
2. Add your packages to the [pkgs](./pkgs) directory and to
   [default.nix](./default.nix)
   * Remember to mark the broken packages as `broken = true;` in the `meta`
     attribute, or travis (and consequently caching) will fail!
   * Library functions, modules and overlays go in the respective directories
3. Choose your CI: Depending on your preference you can use github actions (recommended) or [Travis ci](https://travis-ci.com).
   - Github actions: Change your NUR repo name and optionally add a cachix name in [.github/workflows/build.yml](./.github/workflows/build.yml) and change the cron timer
     to a random value as described in the file
   - Travis ci: Change your NUR repo name and optionally your cachix repo name in 
   [.travis.yml](./.travis.yml). Than enable travis in your repo. You can add a cron job in the repository settings on travis to keep your cachix cache fresh
5. Change your travis and cachix names on the README template section and delete
   the rest
6. [Add yourself to NUR](https://github.com/nix-community/NUR#how-to-add-your-own-repository) -->
