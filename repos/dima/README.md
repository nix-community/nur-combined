Nix Flakes
==========

My collection of Nix flakes for third–party software

Developing
----------

To build a package, run:
```sh
nix build .#package # Using flakes.

nix-build --arg pkgs 'import <nixpkgs> {}' -A package # Without flakes.
```

Links
-----

* [Repository][1]
* [Source][2]
* [Pull Request][3]

[1]: https://nur.nix-community.org/repos/dima/ (This project in the NUR)
[2]: https://gitlab.com/-/p/79327771 (The source code of this project on GitLab)
[3]: https://github.com/nix-community/NUR/pull/1137 (My pull request to add this project to the NUR)
