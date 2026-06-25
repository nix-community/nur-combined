# Contributing to `bun2nix`

Thinking about contributing? - All pull requests and issues are welcome and I will work with you to attempt to resolve them in a resonable amount of time.

To help with that, here are some developer notes:

## Tests

All tests for this project are ran through `nix flake check` and are a good way of checking if the whole project works. This project runs [CI provided by nix-community](https://nix-community.org/continuous-integration/).

## Documentation

More documentation is always welcome, if you have any ideas for anything more which could be documented do make a contribution. For now, the documentation is an [mdbook](https://rust-lang.github.io/mdBook/) in `docs/`.

## Formatting

[Treefmt](https://github.com/numtide/treefmt-nix) has been setup for this repo to keep code styling clean and git diffs as small as possible, it is checked for automatically, but please remember to run `nix fmt` before making a pull request.
