# Talon Beta Nix User Package

This NixPkgs User Repository contains an expression for building the beta
version of `talonvoice`. This requires a subscription on Patreon:

https://www.patreon.com/lunixbochs

For details on setting up the Nixpkgs User Repository, see

https://github.com/nix-community/NUR/blob/master/README.md

## beta-src.nix

By default this will use `./src.nix`, which is the public version. If the
`./beta-src` file exists, it will prefer it instead. Generate that file by
running `talon-src <url>`, where URL is provided on the private beta slack
channel.

After computing the release information, this script will install talon.

## Systemd Unit

This provides a basic `systemd --user` service file for running `talon` with
reduced privileges.

## Contributions

Pull requests improving the nix expressions are welcome!

## TODO

- The latest non-beta src does not work (QT plugin error). I only use the beta
  version, though, and at some point latest will likely use the same QT, so just
  wait it out.
