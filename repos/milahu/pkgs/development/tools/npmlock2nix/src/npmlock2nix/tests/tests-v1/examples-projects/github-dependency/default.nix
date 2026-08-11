{ pkgs ? import ../../../../nix { } }:

pkgs.npmlock2nix.v1.node_modules {
  src = ./.;
  packageJson = ./package.json;
  packageLockJson = ./package-lock.json;
  githubSourceHashMap = {
    tmcw.leftpad.db1442a0556c2b133627ffebf455a78a1ced64b9 = "1zyy1nxbby4wcl30rc8fsis1c3f7nafavnwd3qi4bg0x00gxjdnh";
  };
}
