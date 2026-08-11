## Already existing Nix projects to target Node.js dependencies

Most attempts to make Nix natively work with Node.js dependencies are built from the perspective of Nix, and only a couple work well. However, none are suitable for a large codebase such as Canva due to some architectural design decisions.

The node2nix project is widely used and [is the recommended way](https://nixos.wiki/wiki/Language-specific_package_helpers#JavaScript_.2F_Node.js) for integrating node packages in nixpkgs. However, it doesn't address the issues above. For example, it only targets projects that expose CLIs. Also, it doesn't provide granularity in terms of the transitive dependencies, providing only a top-level package as a single derivation. This means it provides no granularity at the Nix derivation level. Only tarballs can be shared, but not the derivations. The local workflow and life-cycle scripting are also not addressed.

The yarn2nix project solves some of the major issues by defining a Nix derivation per npm package, which provides granularity. However, it still has limitations (at the moment of writing, 9 Aug 2021):

- It doesn’t allow dependency cycles.
- It generates an additional file that needs to be checked into the repository.
- The classic Node.js `node_modules` nested folder structure that the project uses doesn’t work. For example, if an npm package `a-dependency` does `require(‘a-dependency/package.json');` it will fail.
- It doesn’t allow dependencies on local packages.
- It only supports the npm and yarn registries, so no custom URLs are possible. For example, a direct GitHub dependency is not allowed.
- It’s difficult for javascript developers to contribute to because it’s written in Haskell and not javascript.
- It doesn't handle life-cycle scripts.


[yarn]: https://classic.yarnpkg.com
[npm]: https://npmjs.com
[nix]: https://nixos.org
[nixpkgs]: https://github.com/NixOS/nixpkgs
[node.js]: https://nodejs.org
[node2nix]: https://github.com/svanderburg/node2nix
[yarn2nix]: https://github.com/Profpatsch/yarn2nix
[canva/canva]: https://github.com/Canva/canva
