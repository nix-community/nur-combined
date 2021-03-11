# lolcommits

This is a [nixpkgs](https://nixos.org/) derivation for [lolcommits](https://github.com/lolcommits/lolcommits/).

It was written to help [this discourse post](https://discourse.nixos.org/t/wrapping-ruby-applications-into-custom-path/9148).

You can easily run it by issuing the following:

```bash
nix run -f https://github.com/fzakaria/lolcommits/archive/master.tar.gz --command lolcommits

Do what exactly?
Try: lolcommits --enable (when in a git repository)
Or:  lolcommits --help
```

It includes all the necessary dependencies such as mplayer & imagemagick

```bash
❯ cat ./result/bin/lolcommits
#! /nix/store/j8vysakw78bpgngba32hfwwikqda9yx2-bash-4.4-p23/bin/bash -e
export PATH='/nix/store/1dysm4zfzss74rw6vvhqbs623rxgygx4-mplayer-1.4/bin:/nix/store/z1fh9yz3mikpmdmxpnbs2i249477q5yf-imagemagick-6.9.11-14/bin'${PATH:+':'}$PATH
exec -a "$0" "/nix/store/xjvpw6p1yqsid0fags6bya607hzd6ff8-lolcommits-0.16.2/bin/.lolcommits-wrapped"  "$@"
```