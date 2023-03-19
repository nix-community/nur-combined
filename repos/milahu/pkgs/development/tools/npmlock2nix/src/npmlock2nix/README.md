
<!-- badges -->
[![License][license-shield]][license-url]
[![Contributors][contributors-shield]][contributors-url]
[![Issues][issues-shield]][issues-url]
[![PRs][pr-shield]][pr-url]
[![Tests][test-shield]][test-url]
[![Matrix][matrix-shield]][matrix-url]

<!-- teaser -->
<br />
<p align="center">
  <h2 align="center">npmlock2nix</h2>
  <p align="center">
    Simple and unit tested solution to nixify npm based packages.
  </p>
</p>

## About

_npmlock2nix_ is a Nix based library that parses the `package.json` and `package-lock.json` files in order to provide different outputs:

1. A `shell` environment
1. A `node_modules` derivation
1. A custom `build` derivation

### Features

- No auto-generated code :heavy_check_mark:
- Works in restricted evaluation :heavy_check_mark:
- GitHub dependencies :heavy_check_mark:
- Unit Tests :heavy_check_mark:
- Integration Tests :heavy_check_mark:

## Getting Started

Since `npmlock2nix` is written entirely in Nix, there aren't any additional prerequisites, it just needs to be imported into your project.

### Installation

The preferred way to provide _npmlock2nix_ to your project is via [niv][niv-url]:

```shell
$ niv add nix-community/npmlock2nix
```

Assuming you are also tracking nixpkgs via niv, you can then provide _npmlock2nix_ to your project as a [nixpkgs overlay][overlay-link]

```nix
# nix/default.nix
let
  sources = import ./sources.nix;
in
  import sources.nixpkgs {
    overlays = [
      (self: super: {
        npmlock2nix = pkgs.callPackage sources.npmlock2nix { };
      })
    ];
  }
```

Assuming the setup above, you can import `nix/default.nix` which will yield a nixpkgs set containing _npmlock2nix_.

## Usage

The following sections outline the main use-case scenarios of _npmlock2nix_.

**Note**: All examples only reflect the most basic scenarios and mandatory arguments. For more details please refer to the [API documentation][api-url].

**Note**: All code snippets provided below assume that _npmlock2nix_ has been imported and is inn scope and that there are valid `package.json` and `package-lock.json` files in the project root.

### Providing A Shell

```nix
npmlock2nix.shell {
  src = ./.;
}
```
The `shell` function creates an environment with the `node_modules` installed that can be used for development purposes.

Please refer to the [API documentation][api-url] for additional information on `shell`.


### Building `node_modules`

```nix
npmlock2nix.node_modules {
  src = ./.;
}
```
The `node_modules` function creates a derivation containing the equivalent of running `npm install` in an impure environment.

Please refer to the [API documentation][api-url] for additional information on `node_modules`.


### Building A Project

```nix
npmlock2nix.build {
  src = ./.;
  installPhase = "cp -r dist $out";
  buildCommands = [ "npm run build" ];
}
```
The `build` function can be used to package arbitrary npm based projects. In order for this to work,
_npmlock2nix_ must be told how to build the project (`buildCommands`) and how to install it (`installPhase`).

Please refer to the [API documentation][api-url] for additional information on `build`.

## Contributing

Contributions to this project are welcome in the form of GitHub Issues or PRs. Please consider the following before creating PRs:

- This project uses nixpkgs-fmt for formatting the Nix code. You can use `nix-shell --run "nixpkgs-fmt ."` to format everything.
- If you are planning to make any considerable changes, you should first present your plans in a GitHub issue so it can be discussed
- _npmlock2nix_ is developed with a strong emphasis on testing. Please consider providing tests along with your contributions and don't hesitate to ask for support.

## Development

When working on _npmlock2nix_ it's highly recommended to use [direnv][direnv-url] and the project's `shell.nix` which provides:

- A commit hook for code formatting via [nix-pre-commit-hooks][nix-pre-commit-hooks-url].
- A `test-runner` script that watches the source tree and runs the unit tests on changes.

The integration tests can be executed via `nix-build -A tests.integration-tests`.

## License

Distributed under the Apache 2.0 License. See [license][license-url] for more details

## Acknowledgements

- [nixpkgs-fmt][nixpkgs-fmt-url]
- [direnv][direnv-url]
- [niv][niv-url]
- [nix-pre-commit-hooks][nix-pre-commit-hooks-url]
- [entr][entr-url]
- [smoke][smoke-url]



<!-- MARKDOWN LINKS & IMAGES -->

[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[issues-shield]: https://img.shields.io/github/issues/Tweag/npmlock2nix.svg?style=for-the-badge
[issues-url]: https://github.com/Tweag/npmlock2nix/issues
[license-shield]: https://img.shields.io/github/license/Tweag/npmlock2nix.svg?style=for-the-badge
[license-url]: https://github.com/Tweag/npmlock2nix/blob/master/LICENSE
[test-shield]: https://img.shields.io/github/workflow/status/Tweag/npmlock2nix/Tests/master?style=for-the-badge
[test-url]: https://github.com/Tweag/npmlock2nix/actions
[pr-shield]: https://img.shields.io/github/issues-pr/Tweag/npmlock2nix.svg?style=for-the-badge
[pr-url]: https://github.com/Tweag/npmlock2nix/pulls
[matrix-shield]: https://img.shields.io/matrix/npmlock2nix:nixos.dev.svg?server_fqdn=matrix.nixos.dev&style=for-the-badge
[matrix-url]: https://matrix.to/#/#npmlock2nix:nixos.dev


<!--Other external links -->
[niv-url]: https://github.com/nmattia/niv
[overlay-link]: https://nixos.org/manual/nixpkgs/stable/#chap-overlays
[api-url]: ./API.md
[direnv-url]: https://direnv.net/
[nix-pre-commit-hooks-url]: https://github.com/cachix/pre-commit-hooks.nix
[nixpkgs-fmt-url]: https://github.com/nix-community/nixpkgs-fmt
[entr-url]: https://github.com/clibs/entr
[smoke-url]: https://github.com/SamirTalwar/Smoke
