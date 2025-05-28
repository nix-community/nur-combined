### Most notable packages
- Some firefox addons that were built from source
- Most [Tsoding](https://github.com/tsoding) software
- [Afio font](https://github.com/awnion/custom-iosevka-nerd-font)
- My own (very bad) `rwds-cli`, program to learn words with, also already available in [flake](https://github.com/dtomvan/rusty-words)

### CI
The CI is [garnix](https://garnix.io). Chances are that when you set the following Nix config:

```ini
extra-substituters = https://cache.garnix.io
extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
```

You will be able to download artifacts without building everything yourself.
(especially `afio-font` can be cumbersome, because it requires an Iosevka
rebuild, but it's not that bad and I have also made `afio-font-bin`)
