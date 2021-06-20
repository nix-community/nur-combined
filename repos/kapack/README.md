[![CI build status](https://github.com/oar-team/nur-kapack/actions/workflows/build-packages.yml/badge.svg?branch=master)](https://github.com/oar-team/nur-kapack/actions?query=branch%3Amaster)
[![Cachix Cache](https://img.shields.io/badge/cachix-capack-blue.svg)](https://capack.cachix.org)

NUR-Kapack repository
=====================

NUR-Kapack contains [Nix](https://nixos.org/) package definitions of the software we work on in the [DataMove](https://team.inria.fr/datamove/) team: OAR, the Batsim ecosystem, Melissa...
This is part of [Nix User Repository](https://github.com/nix-community/NUR).

Packages of released versions defined in this repository are built regularly on CI and stored on a [Cachix](https://cachix.org/) binary cache. You can use it to just fetch prebuilt binaries instead of rebuilding them with the following command.

```bash
# Install cachix
nix-env -iA cachix -f https://cachix.org/api/v1/install

# Enable our binary cache for your builds
cachix use capack
```

Interactive usage
-----------------

You can enter shells that contain some of our packages with `nix run`.

```bash
# Essential Batsim tools in a single shell (latest release of each tool)
nix run -f https://github.com/oar-team/nur-kapack/archive/master.tar.gz batsim batsched pybatsim batexpe

# The same, but with latest commit on master branch of each tool
nix run -f https://github.com/oar-team/nur-kapack/archive/master.tar.gz batsim-master batsched-master pybatsim-master batexpe-master
```

You can also install packages in your [Nix profile](https://nixos.org/manual/nix/unstable/package-management/profiles.html) with `nix-env`.

```bash
# Install Batsim latest release in your profile
nix-env -f https://github.com/oar-team/nur-kapack/archive/master.tar.gz -iA batsim
```

Usage from Nix expressions
--------------------------

You can write Nix expression to define environments that use our packages.
Assuming that you have a file named `shell.nix` that has the following content, you can enter the defined shell by calling `nix-shell`.
```nix
{ kapack ? import
    (fetchTarball "https://github.com/oar-team/nur-kapack/archive/master.tar.gz")
  {}
}:

kapack.pkgs.mkShell rec {
  name = "tuto-env";
  buildInputs = [
    kapack.batsim
    kapack.batsched
    kapack.pybatsim
    kapack.batexpe
  ];
}
```

If you want to pin the NUR-Kapack version you use, you can do one of the following.

- Use a pinned tarball from GitHub such as `https://github.com/oar-team/nur-kapack/archive/2518733fefc28290ecffe44c3234eb2a36b731cd.tar.gz`
- Use [Nix Flakes](https://nixos.wiki/wiki/Flakes)

Usage à la NUR
--------------

As NUR-Kapack is a NUR, you can use our packages as it is done with other NURs.
Please refer to the [official NUR documentation](https://github.com/nix-community/NUR) for this usage.
