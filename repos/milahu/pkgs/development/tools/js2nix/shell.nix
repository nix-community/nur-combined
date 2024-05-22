{ pkgs ? import
    (
      builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/13e0d337037b3f59eccbbdf3bc1fe7b1e55c93fd.tar.gz"
    )
    { }
}:

let
  js2nix = pkgs.callPackage ./default.nix { };
  env = js2nix {
    package-json = ./package.json;
    yarn-lock = ./yarn.lock;
  };
in
pkgs.mkShell {
  # Give the nix-build access to resulting artifact directly with an a standart folder 
  # structure instead of the structure that would be picked up by nodejs pachage setup-hook.
  # To create a folder type:
  #   nix-build -o ./node_modules -A env.nodeModules ./shell.nix
  passthru.env = env;
  buildInputs = [
    (env.nodeModules.override { prefix = "/lib/node_modules"; })
    pkgs.nodejs
    js2nix.bin
    js2nix.proxy
    js2nix.node-gyp
  ];
}
