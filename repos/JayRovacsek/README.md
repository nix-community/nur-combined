# nix-config

![What in tarnation](https://github.com/JayRovacsek/ncsg-presentation-feb-2022/blob/main/resources/what-in.jpg?raw=true)

This repo contains my flake'd nix configs, it's a work in progress and currently being migrated to from [my old configs](https://github.com/JayRovacsek/dotfiles)

Note that while flakes are a beautiful thing in which we could have many repositories to then bind together via inputs & make configurations
far more contained in each repository, this is intentionally a mono-flake. It includes overlays, packages and configurations for both linux and darwin
hosts to centralise the configuration and possibly help myself and/or viewers understand the spiderweb of \*.nix files.

## Using this/something like this

Bootstrap yourself some Nix, ensure you've got flake support and then depending on if you're using Linux or Darwin modify the relevant nixosConfigurations/darwinConfigurations

Note that in building/switching to the config you're after you'll need to either define _what_ config you're using or ensure the name of the config matches your target system hostname.

To arbitrarily test/dry-build a config you can use standard flake pathing, for example on a linux system:

```sh
# Match on hostname
nixos-rebuild dry-build --flake .#
# Build alakazam
nixos-rebuild dry-build --flake .#alakazam
```

Of-course these could just be tested using the subcommand for `nixos-rebuild` of `test`.

```sh
# Match on hostname
nixos-rebuild test --flake .#
# Test alakazam
nixos-rebuild test --flake .#alakazam
```

## Fearless Refactor

Historically there is a fear of updates due to how they've been breaking in various ways for a number of common systems. Generations save us here in
this aspect, but what if I want to refactor large swathes of my nix code and be certain I haven't changed the status-quo for the most part?

It seems thus far in my testing you could abuse a small amount of disk space to be _really_ confident in refactor efforts, firstly make sure you create a branch
for your work in progress, then create any number of changes. Copy the repo to another folder (to be honest this is likely possible to do in the single folder
and I'm just yet to read the docs far enough), checkout the work you want to compare in one folder and the original work in another then:

```sh
# Linux Old -> New
nix store diff-closures ../nix-config-tmp#nixosConfigurations.HOST.config.system.build.toplevel .#nixosConfigurations.HOST.config.system.build.toplevel --no-write-lock-file > output

# Darwin Old -> New
nix store diff-closures ../nix-config-tmp#darwinConfigurations.HOST.config.system.build.toplevel .#darwinConfigurations.HOST.config.system.build.toplevel --no-write-lock-file > output
```

Note; if the systems utilise new package versions those of-course will be downloaded for comparison, but otherwise this should be relatively like-for-like
if you were to not modify the flake inputs otherwise.

## Debugging

If you also have spent countless hours just wanting to do and not RTFM like I have, you might want to utilise the repl and/or `builtins.trace` when the time comes.

To load this (or any flake via the repl):

```sh
nix repl # You should be in a repl now, ensure you remember exit is Ctrl + D

:lf . # Period here is just the path to a directory containing a flake. Here we assume it is in $PWD

# An example; to look at what vlans exist of jigglypuff:
nixosConfigurations.jigglypuff.options.networking.vlans.value

# Which should return the below at time of writing
{ dns = { ... }; }

# Delving deeper on this is easy as using shell history and tabbing for auto-complete
nixosConfigurations.jigglypuff.options.networking.vlans.v
alue.dns.interface

# For darwin configs, example of exploring the options applied against cloyster:
darwinConfigurations.cloyster.options
```

![Would I recommend nixos?](./resources/recommend.jpg)
