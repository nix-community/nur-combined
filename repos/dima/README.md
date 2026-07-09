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
* [NUR Combined directory][3]
* [Pull request][4]
* [Commit][5]
* [Merge commit][6]

[1]: https://nur.nix-community.org/repos/dima/ (This project in the NUR)
[2]: https://gitlab.com/-/p/79327771 (The source code of this project on GitLab)
[3]: https://github.com/nix-community/nur-combined/tree/main/repos/dima (The directory for this NUR repository in the nur-combined GitHub repository)
[4]: https://github.com/nix-community/NUR/pull/1137 (My pull request to add this project to the NUR)
[5]: https://github.com/nix-community/NUR/commit/a9e86abb7def647b6ac4d016378ea1cbea61cdf6 (The commit which adds my project to the NUR)
[6]: https://github.com/nix-community/NUR/commit/e94618103dd622d1209d0a030067ac0cb5b84113 (The commit which merged my commit)
