# [some-pkgs](https://nur.nix-community.org/repos/some-pkgs/)

- Based on [NUR](https://github.com/nix-community/NUR)
- A template repo: https://github.com/nix-community/nur-packages-template

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/SomeoneSerge/pkgs/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-pkgs-blue.svg)](https://pkgs.cachix.org)

## Deploying the undeployable with Nix

Sci-Comp and Deep Learning projects are notoriously hard to build and deploy:
even to satisfy the build-time dependencies people inevitably fall back to [building things in Docker](https://github.com/NVlabs/instant-ngp/issues/20) (build-time isolation).
And when building things in Docker, they would some times fetch dependencies through conda.
And then they would take the stock they've built through sweat and blood, and run it in containers (run-time isolation).
And that is just the beginning: later, for example, they'll seek for ways to establish a communication between the container and the host system's X-server (that they've put so much effort in isolating from).

When they have gone through all these pains and struggles, and had cheered at a running visualizer from some old baseline project, in a month or two they should probably find that, in spite of all effort, their hard-won trophey won't acknowledge their CUDA installation anymore, and nobody knows why.

Now, have you really considered if there ever was a need for Docker or Kubernetes?

Enter [Nix (for building things) and NixOS](https://nixos.org/) (for setting up the runtime environment, notably `/run/opengl-driver/lib`):

https://user-images.githubusercontent.com/9720532/162585397-7528d249-4db1-4931-930c-3929775d61ea.mp4

Transcript:

```bash
nix build github:SomeoneSerge/pkgs/unfree#instant-ngp.data
nix build github:SomeoneSerge/pkgs/unfree#instant-ngp.configs
nix run github:SomeoneSerge/pkgs/unfree#instant-ngp -- --scene ./result-data/nerf/fox/ --config ./result-configs/nerf/base.json
```

DISCLAIMER:

> - The video demonstrates https://github.com/NVlabs/instant-ngp
> - **`/run/opengl-driver/lib/`**
>
>   Nix deploys its executables and libraries with absolute paths to
>   concrete versions of their dependencies that are guaranteed to work
>   (e.g. through Runpath in ELF headers on Linux).
>   However, this doesn't apply to hardware-specific dependencies, like graphics and compute drivers.
>   For `nix run` to work with OpenGL or CUDA-enabled applications,
>   one needs to symlink their hardware-dependent drivers
>   in `/run/opengl-driver/lib`. NixOS does that automatically when
>   [`hardware.opengl.enable = true`](https://nixos.org/manual/nixos/stable/options.html#opt-hardware.opengl.enable)
> - **NixGL**
>
>   When running on Ubuntu&c one may face an issue that their graphics driver
>   links against a revision libc older than the one used by this repo. In
>   these cases a temporary workaround could be
>   [NixGL](https://github.com/guibou/nixGL).
