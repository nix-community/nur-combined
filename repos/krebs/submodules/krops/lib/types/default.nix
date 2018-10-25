{ lib }@args: let {

  body = lib.foldl' (res: path: res // import path args) {} [
    ./populate.nix
    ./posix.nix
  ];

}
